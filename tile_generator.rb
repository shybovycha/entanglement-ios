# all possible tiles: 66
# generated with:
#
#   a = (0..11).to_a.combination(2).to_a
#   a.map {|p| a.inject([p]) {|acc, e| ((acc.flatten - e) == acc.flatten) ? acc << e : acc }}
#
# results:
#
#   ["0123456789ab", "0213456789ab", "0312456789ab", "0412356789ab", "0512346789ab", "0612345789ab", "0712345689ab", "0812345679ab", "0912345678ab", "0a123456789b", "0b123456789a", "1203456789ab", "1302456789ab", "1402356789ab", "1502346789ab", "1602345789ab", "1702345689ab", "1802345679ab", "1902345678ab", "1a023456789b", "1b023456789a", "2301456789ab", "2401356789ab", "2501346789ab", "2601345789ab", "2701345689ab", "2801345679ab", "2901345678ab", "2a013456789b", "2b013456789a", "3401256789ab", "3501246789ab", "3601245789ab", "3701245689ab", "3801245679ab", "3901245678ab", "3a012456789b", "3b012456789a", "4501236789ab", "4601235789ab", "4701235689ab", "4801235679ab", "4901235678ab", "4a012356789b", "4b012356789a", "5601234789ab", "5701234689ab", "5801234679ab", "5901234678ab", "5a012346789b", "5b012346789a", "6701234589ab", "6801234579ab", "6901234578ab", "6a012345789b", "6b012345789a", "7801234569ab", "7901234568ab", "7a012345689b", "7b012345689a", "8901234567ab", "8a012345679b", "8b012345679a", "9a012345678b", "9b012345678a", "ab0123456789"]
#
# converting (u, v) coordinates to (x, y):
#
#   uv2xy u v = (((u - v) * 3/2), ((u + v) * sqrt(3) / 2))
#

require 'RMagick'
require 'ruby-progressbar'

class TileGenerator
    def initialize(side_length, params = { cx: 0, cy: 0, stroke: 2, stroke_color: '#000', path_color: '#bde', highlight_color: '#f65', path_stroke: 4, output_dir: 'tiles/' })
        @side_length, @tile_params = side_length, params
    end

    def generate_all_tiles!
        highlight_indices = tile_variations
        all_connections = all_possible_connections

        output_dir = @tile_params[:output_dir] || 'tiles/'
        Dir.mkdir(output_dir) unless Dir.exists?(output_dir)

        progressbar = ProgressBar.create(title: 'Generating tiles', total: highlight_indices.size * all_connections.size, format: '%t:|%B|%J%%')

        all_connections.map do |connections|
            highlight_indices.map do |highlight|
                svg_string = svg_hexagon(connections, highlight, side_length: @side_length)
                svg_string2x = svg_hexagon(connections, highlight, generate_2x: true, side_length: @side_length)

                filename = File.join(output_dir, "tile_#{connections2hex(connections)}_#{connections2hex(highlight)}.png")
                filename2x = File.join(output_dir, "tile_#{connections2hex(connections)}_#{connections2hex(highlight)}@2x.png")

                svg2png(svg_string, filename)
                svg2png(svg_string2x, filename2x)

                progressbar.increment
            end
        end
    end

    public

    def tile_variations
        # 63 variations for each tile - with each connections' combination highlighted
        (0..5).map { |len| (0..5).to_a.combination(len).to_a }.flatten(1)
    end

    def connections2hex(connections)
        connections.flatten.map { |c| c.to_s(16) }.join
    end

    def svg2png(svg_string, png_filename)
        img = Magick::ImageList.new.from_blob(svg_string) {
          self.format = 'SVG'
          self.background_color = 'transparent'
        }

        img.flatten_images.write png_filename
    end

    def svg_hexagon(connections, highlight = [], params = {})
        # pre-defined coordinates
        points = [[0,0], [100,0], [150,87], [100,173], [0,173], [-50,87]]
        pins = [[33,0], [66,0], [116,29], [132,58], [132,116], [116,145], [66,173], [33,173], [-16,145], [-32,116], [-32,58], [-16,29]]

        # overloaded params
        side_length = params[:side_length] || @tile_params[:side_length] || 100
        stroke = params[:stroke] || @tile_params[:stroke] || 2
        path_stroke = params[:path_stroke] || @tile_params[:path_stroke] || 4
        stroke_color = params[:stroke_color] || @tile_params[:stroke_color] || '#000'
        highlight_color = params[:highlight_color] || @tile_params[:highlight_color] || '#f65'
        path_color = params[:path_color] || @tile_params[:path_color] || '#bde'
        generate_2x = params[:generate_2x] || false

        # fix coordinates so that we do not need cx and cy to be >0 anymore
        cx = 50 + (stroke)
        cy = (stroke)

        # get @2x params
        if generate_2x
            side_length *= 2
            cx *= 2
            cy *= 2
            stroke *= 2
            path_stroke *= 2
        end

        # calculate center so that all paths' curves will be aligned according to that center
        center_x, center_y = cx + (0.5 * side_length), cy + (0.87 * side_length)

        # find SVG size
        width = 2 * (side_length + (stroke * 2))
        height = 1.73 * (side_length + (stroke * 2))

        # generate hexagonal shape vertices
        vertices = points.map do |point|
            "#{cx + ((point[0] / 100.0) * side_length)},#{cy + ((point[1] / 100.0) * side_length)}"
        end.join(' ')

        # generate paths (connections) and add coloring for highlighted ones
        paths = connections.each_with_index.map do |pair, index|
            p1, p2 = pins[pair[0]], pins[pair[1]]
            p1[0], p1[1] = cx + ((p1[0] / 100.0) * side_length), cy + ((p1[1] / 100.0) * side_length)
            p2[0], p2[1] = cx + ((p2[0] / 100.0) * side_length), cy + ((p2[1] / 100.0) * side_length)

            path_fragment_color = highlight.include?(index) ? highlight_color : path_color

            "<path d=\"M #{p1[0]},#{p1[1]} Q #{center_x},#{center_y} #{p2[0]},#{p2[1]}\" stroke=\"#{path_fragment_color}\" />"
        end.join("\n")

        # the final SVG
        <<-SVG
        <svg width="#{width}" height="#{height}">
            <polygon points="#{vertices}" style="fill:#eee;stroke:none;" />
            <g stroke="#{path_color}" stroke-width="#{path_stroke}" fill="none">
                #{paths}
            </g>
            <polygon points="#{vertices}" style="fill:none;stroke:#{stroke_color};stroke-width:#{stroke}" />
        </svg>
        SVG
    end

    def all_possible_connections
        a = (0..11).to_a.combination(2)
        a.map { |p| a.inject([p]) { |acc, e| ((acc.flatten - e) == acc.flatten) ? acc << e : acc } }
    end
end

if __FILE__ == $0
    gen = TileGenerator.new(100, output_dir: 'tiles.atlas')
    gen.generate_all_tiles!
end
