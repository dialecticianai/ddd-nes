#!/opt/homebrew/bin/perl
# png2chr.pl — Convert indexed PNG to NES CHR-ROM binary
#
# Usage:
#   png2chr.pl input.png output.chr
#   png2chr.pl --generate-test output.png   # Generate a test tileset PNG
#
# Input: 128x128 indexed PNG (4 colors max, 256 8x8 tiles)
# Output: 8192-byte CHR-ROM binary (one pattern table)
#
# NES CHR format: each 8x8 tile = 16 bytes (two 8-byte bitplanes)
#   Plane 0 (bytes 0-7):  bit 0 of each pixel
#   Plane 1 (bytes 8-15): bit 1 of each pixel
#   Pixel value = (plane1_bit << 1) | plane0_bit

use strict;
use warnings;
use Imager;

my $usage = "Usage: $0 input.png output.chr\n       $0 --generate-test output.png\n";

if (@ARGV == 2 && $ARGV[0] eq '--generate-test') {
    generate_test_png($ARGV[1]);
    exit 0;
}

die $usage unless @ARGV == 2;
my ($input, $output) = @ARGV;

# Read PNG
my $img = Imager->new;
$img->read(file => $input) or die "Cannot read $input: " . $img->errstr . "\n";

# Validate dimensions
my ($w, $h) = ($img->getwidth, $img->getheight);
die "Image must be 128x128, got ${w}x${h}\n" unless $w == 128 && $h == 128;

# Read all pixels, map to 0-3 palette indices
# For indexed images, use the index directly
# For RGB images, quantize to 4 unique colors
my @pixels;  # 128x128 array of values 0-3

if ($img->type eq 'paletted') {
    my $colors = $img->colorcount;
    die "Paletted image has $colors colors, max 4\n" if $colors > 4;
    for my $y (0 .. $h - 1) {
        my @indices = $img->getsamples(y => $y, channels => [0], type => 'index');
        # getsamples with index type returns palette indices
        push @pixels, \@indices;
    }
} else {
    # RGB image: collect unique colors, map to indices
    my %color_map;
    my @color_order;
    for my $y (0 .. $h - 1) {
        my @row;
        for my $x (0 .. $w - 1) {
            my $c = $img->getpixel(x => $x, y => $y);
            my @rgb = $c->rgba;
            my $key = sprintf("%02x%02x%02x", @rgb[0..2]);
            unless (exists $color_map{$key}) {
                die "More than 4 unique colors in image (found at pixel $x,$y)\n"
                    if @color_order >= 4;
                $color_map{$key} = scalar @color_order;
                push @color_order, $key;
            }
            push @row, $color_map{$key};
        }
        push @pixels, \@row;
    }
    printf STDERR "Mapped %d unique colors to indices 0-%d\n",
        scalar @color_order, $#color_order;
}

# Convert to CHR-ROM: 16x16 grid of 8x8 tiles
my $chr = '';
for my $tile_row (0 .. 15) {
    for my $tile_col (0 .. 15) {
        my $base_y = $tile_row * 8;
        my $base_x = $tile_col * 8;

        # Each tile: 8 bytes plane 0, then 8 bytes plane 1
        my (@plane0, @plane1);
        for my $row (0 .. 7) {
            my ($p0, $p1) = (0, 0);
            for my $col (0 .. 7) {
                my $px = $pixels[$base_y + $row][$base_x + $col];
                # bit 0 goes to plane 0, bit 1 goes to plane 1
                $p0 = ($p0 << 1) | ($px & 1);
                $p1 = ($p1 << 1) | (($px >> 1) & 1);
            }
            push @plane0, $p0;
            push @plane1, $p1;
        }
        $chr .= pack('C*', @plane0, @plane1);
    }
}

die "Internal error: CHR data is " . length($chr) . " bytes, expected 4096\n"
    unless length($chr) == 4096;

# Pad to 8192 bytes (full CHR-ROM bank = two pattern tables)
$chr .= "\x00" x 4096;

open my $fh, '>:raw', $output or die "Cannot write $output: $!\n";
print $fh $chr;
close $fh;

printf "Wrote %d bytes to %s (256 tiles)\n", length($chr), $output;

# --- Test tileset generator ---

sub generate_test_png {
    my ($outfile) = @_;

    my $img = Imager->new(xsize => 128, ysize => 128, channels => 3);

    # 4 colors: black, dark gray, light gray, white
    my @colors = (
        Imager::Color->new(0, 0, 0),        # index 0: black
        Imager::Color->new(85, 85, 85),      # index 1: dark gray
        Imager::Color->new(170, 170, 170),   # index 2: light gray
        Imager::Color->new(255, 255, 255),   # index 3: white
    );

    # Fill with color 0 (black)
    $img->box(filled => 1, color => $colors[0]);

    # Tile 0 (0,0): leave blank (all color 0)

    # Tile 1 (1,0): solid fill color 1 (dark gray)
    draw_solid($img, 1, 0, $colors[1]);

    # Tile 2 (2,0): solid fill color 2 (light gray)
    draw_solid($img, 2, 0, $colors[2]);

    # Tile 3 (3,0): solid fill color 3 (white)
    draw_solid($img, 3, 0, $colors[3]);

    # Tile 4 (4,0): checkerboard (colors 0 and 3)
    draw_checker($img, 4, 0, $colors[0], $colors[3]);

    # Tile 5 (5,0): diagonal stripes (colors 1 and 2)
    draw_diagonal($img, 5, 0, $colors[1], $colors[2]);

    # Tile 6 (6,0): horizontal stripes (colors 0 and 2)
    draw_hstripes($img, 6, 0, $colors[0], $colors[2]);

    # Tile 7 (7,0): border frame (color 3 border, color 1 fill)
    draw_border($img, 7, 0, $colors[3], $colors[1]);

    $img->write(file => $outfile, type => 'png')
        or die "Cannot write $outfile: " . $img->errstr . "\n";
    print "Generated test tileset: $outfile (128x128, 4 colors, 8 distinct tiles)\n";
}

sub draw_solid {
    my ($img, $tx, $ty, $color) = @_;
    my ($bx, $by) = ($tx * 8, $ty * 8);
    $img->box(xmin => $bx, ymin => $by, xmax => $bx + 7, ymax => $by + 7,
              filled => 1, color => $color);
}

sub draw_checker {
    my ($img, $tx, $ty, $c0, $c1) = @_;
    my ($bx, $by) = ($tx * 8, $ty * 8);
    for my $y (0..7) {
        for my $x (0..7) {
            $img->setpixel(x => $bx + $x, y => $by + $y,
                           color => (($x + $y) % 2 == 0 ? $c0 : $c1));
        }
    }
}

sub draw_diagonal {
    my ($img, $tx, $ty, $c0, $c1) = @_;
    my ($bx, $by) = ($tx * 8, $ty * 8);
    for my $y (0..7) {
        for my $x (0..7) {
            $img->setpixel(x => $bx + $x, y => $by + $y,
                           color => (($x + $y) % 2 == 0 ? $c0 : $c1));
        }
    }
    # Actually make it diagonal, not checker
    for my $y (0..7) {
        for my $x (0..7) {
            my $stripe = int(($x + $y) / 2) % 2;
            $img->setpixel(x => $bx + $x, y => $by + $y,
                           color => $stripe ? $c1 : $c0);
        }
    }
}

sub draw_hstripes {
    my ($img, $tx, $ty, $c0, $c1) = @_;
    my ($bx, $by) = ($tx * 8, $ty * 8);
    for my $y (0..7) {
        my $color = ($y % 2 == 0) ? $c0 : $c1;
        for my $x (0..7) {
            $img->setpixel(x => $bx + $x, y => $by + $y, color => $color);
        }
    }
}

sub draw_border {
    my ($img, $tx, $ty, $border, $fill) = @_;
    my ($bx, $by) = ($tx * 8, $ty * 8);
    for my $y (0..7) {
        for my $x (0..7) {
            my $is_border = ($x == 0 || $x == 7 || $y == 0 || $y == 7);
            $img->setpixel(x => $bx + $x, y => $by + $y,
                           color => $is_border ? $border : $fill);
        }
    }
}
