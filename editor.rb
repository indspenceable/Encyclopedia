require 'rubygame'
require 'YAML'

class Quit < Exception
end

TEXT_AREA = 18
BUFFER = 4

begin
  level = nil
  tiles = Rubygame::Surface.load('template_tiles.png')
  SCREEN_WIDTH = tiles.w/16
  SCREEN_HEIGHT = tiles.h/16
  file_name = "dump.yaml"
  if ARGV.length == 0
    # default to a 100 x 100 level
    #level = LevelMapping.new SCREEN_WIDTH, SCREEN_HEIGHT
    level = LevelMapping.new SCREEN_WIDTH, SCREEN_HEIGHT
  elsif ARGV.length == 1
    # load a level
    level = YAML.load_file ARGV[0]
    file_name = ARGV[0]
  else
    level = LevelMapping.new ARGV[0].to_i, ARGV[1].to_i
  end
  screen = Rubygame::Screen.new [2*tiles.w+BUFFER, tiles.h+TEXT_AREA]
  queue = Rubygame::EventQueue.new
  queue.enable_new_style_events()

  fill  = Rubygame::Surface.new [16,16]
  fill.fill [0,255,0]

  offset = [0,0]
  current_tile = [0,0]
  current_location = [0,0]

  mode = true
  mouse_over_tiles = false

  currently_editing = false
  current_tool = :pencil
  current_string = nil

#font
  Rubygame::TTF.setup
  font = Rubygame::TTF.new('freesans.ttf', 18)


  loop do
    queue.each do |e|
      raise Quit.new if e.is_a? Rubygame::Events::QuitRequested      
      if e.is_a? Rubygame::Events::KeyPressed
        if currently_editing
          if e.key == :return
            currently_editing = false 
          elsif e.key == :backspace
            if file_name.size > 1
              file_name= file_name[0,file_name.size-1]
            else
              file_name = ""
            end
          else
            file_name += e.string
          end
        else

          offset[0] += 1 if e.key == :d
          offset[0] -= 1 if e.key == :a
          offset[1] += 1 if e.key == :s
          offset[1] -= 1 if e.key == :w

          current_tile[0] += 1 if e.key == :l
          current_tile[0] -= 1 if e.key == :h
          current_tile[1] += 1 if e.key == :j
          current_tile[1] -= 1 if e.key == :k
    
          File.open(file_name, "w") do |f|
            f << YAML.dump(level)
            puts "Saved level."
          end if e.key == :m

          if e.key == :f
            currently_editing = true  
          end
          current_tool = :bucket if e.key == :b

          current_tool = :pencil if e.key == :x
        end

      end
      if (e.is_a? Rubygame::Events::MouseMoved) || (e.is_a? Rubygame::Events::MousePressed)
        #set the offset
        if e.pos[0] < tiles.w
          mouse_over_tiles = false
          current_location[0] = (e.pos[0]/16)+offset[0]
          current_location[1] = ((e.pos[1]-TEXT_AREA)/16)+offset[1]

          button = nil
          button = e.button if e.is_a? Rubygame::Events::MousePressed
          button = e.buttons[0] if e.is_a?(Rubygame::Events::MouseMoved) && e.buttons.size > 0
          if e.pos[1] > TEXT_AREA
            if button == :mouse_left
              if current_tool == :pencil
                level.map[current_location[0]][current_location[1]] = current_tile.dup
              else
                look_for = level.map[current_location[0]][current_location[1]].dup
                to_change = [current_location.dup]
                to_consider = [current_location.dup]
                current_index = 0
                while to_consider.size > current_index
                  c = to_consider[current_index] 
                  current_index += 1

                  if c[0] < level.Width && c[0] >= 0 && c[1] < level.Height && c[1] >= 0 && level.map[c[0]][c[1]] == look_for
                    to_change << c
                    new = [c[0],c[1]+1]
                    to_consider << new if (!to_consider.include? new)
                    new = [c[0],c[1]-1]
                    to_consider << new if (!to_consider.include? new)
                    new = [c[0]+1,c[1]]
                    to_consider << new if (!to_consider.include? new)
                    new = [c[0]-1,c[1]]
                    to_consider << new if (!to_consider.include? new)
                  end
                end
                to_change.each do |loc|
                  level.map[loc[0]][loc[1]] = current_tile.dup
                end
              end
            elsif button == :mouse_right
              current_tile = level.map[current_location[0]][current_location[1]].dup
            end
          end
        else
          mouse_over_tiles = true
          current_location[0] = ((e.pos[0]-tiles.w-BUFFER)/16)+offset[0]
          current_location[1] = ((e.pos[1]-TEXT_AREA)/16)+offset[1]
          if e.pos[0] > tiles.w + BUFFER
            if (e.is_a? Rubygame::Events::MousePressed) || e.buttons.length > 0 
              current_tile = current_location.dup
            end
          end
        end
      end
      #level.map[current_location[0]][current_location[1]] = current_tile.dup if (e.is_a?(Rubygame::Events::MousePressed)) && !mouse_over_tiles
      #current_tile = current_location.dup if e.is_a?(Rubygame::Events::MousePressed) && mouse_over_tiles
    end

    # fix our offset
    offset[0] = level.Width-SCREEN_WIDTH if offset[0] >= level.Width-SCREEN_WIDTH
    offset[0] = 0 if offset[0] < 0
    offset[1] = level.Height-SCREEN_HEIGHT if offset[1] >= level.Height-SCREEN_HEIGHT
    offset[1] = 0 if offset[1] < 0

    screen.fill [0,0,100]

    #draw the layout
    SCREEN_WIDTH.times do |x|
      SCREEN_HEIGHT.times do |y|
        tiles.blit(screen,
                   [x*16,y*16 + TEXT_AREA], 
                   [level.map[offset[0]+x][offset[1]+y][0]*16,
                     level.map[offset[0]+x][offset[1]+y][1]*16,
                     16,
                     16])
      end
    end

    #draw the tiles
    tiles.blit(screen,
               [tiles.w+BUFFER,TEXT_AREA])
    if !mouse_over_tiles
      tiles.blit(screen,
                 [(current_location[0]-offset[0])*16, 
                   TEXT_AREA+(current_location[1]-offset[1])*16],
                   [current_tile[0]*16,
                     current_tile[1]*16,
                     16,
                     16])
    end
    fill.blit(screen,
              [current_tile[0]*16+tiles.w+4, current_tile[1]*16+TEXT_AREA])
    font.render(current_tool.to_s, false, [255,255,255]).blit(screen,[0,0])
    font.render(file_name, false, [255,255,255]).blit(screen,[tiles.w,0]) if file_name.size > 0

    screen.update
  end
rescue Quit => e
ensure
  Rubygame.quit
end
