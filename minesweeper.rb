require "colorize"

class Minesweeper

  COLORS = {
    "1" => :light_blue,
    "2" => :green,
    "3" => :light_magenta,
    "4" => :magenta,
    "5" => :light_red,
    "6" => :light_cyan,
    "7" => :light_green,
    "8" => :light_black,
    "X" => :red
  }

  attr_reader :width, :height, :board, :hidden, :over

  def initialize(width = 10, height = 10, num_mines = 10)
    raise "Number of mines exceeds board size" if num_mines > width * height
    @width = width
    @height = height
    @num_mines = num_mines
    @board = Array.new(height) { Array.new(width) {" "} }
    @hidden = {}
    @over = false
    createMines(num_mines)
    createNums
    createHidden
  end

  def createMines(n)
    until n <= 0
      x = rand(width)
      y = rand(height)
      if board[x][y] == " "
        board[x][y] = "X"
        n -= 1
      end
    end
  end

  def createNums
    0.upto(width-1) do |i|
      0.upto(height-1) do |j|
        next if board[i][j] == "X"

        count = 0

        if i > 0
          count += 1 if board[i-1][j-1] == "X" unless j == 0
          count += 1 if board[i-1][j] == "X"
          count += 1 if board[i-1][j+1] == "X"
        end

        count += 1 if board[i][j-1] == "X" unless j == 0
        count += 1 if board[i][j+1] == "X"

        if i < width-1
          count += 1 if board[i+1][j-1] == "X" unless j == 0
          count += 1 if board[i+1][j] == "X"
          count += 1 if board[i+1][j+1] == "X"
        end

        @board[i][j] = count.to_s
      end
    end
  end

  def createHidden
    0.upto(width-1) do |i|
      0.upto(height-1) do |j|
        @hidden[i.to_s + " " + j.to_s] = true
      end
    end
  end

  def step
    until over
      display(true)
      get_move
      won?
    end
    display(false)
    puts "WINNER"
  end

  def display(hide)
    system("clear")
    puts "MINES #{@num_mines}".colorize(:red)
    print "  "
    0.upto(width-1) do |i|
      print i.to_s.colorize(:yellow)
      print " " if i < width
    end
    puts

    board.each_with_index do |row, i|
      print i.to_s.colorize(:light_yellow) + " "
      row.each_with_index do |el, j|
        if hide
          if hidden[i.to_s + " " + j.to_s]
            print " "
          else
            print el.to_s.colorize(COLORS[el])
          end
        else
          print el.to_s.colorize(COLORS[el])
        end

        print " " if j < row.length
      end
      puts
    end

  end

  def get_move
    print "Input your move in " + "x".colorize(:light_yellow) + "," + "y".colorize(:yellow) + " format: "
    pos = gets.chomp.split(",")

    if pos.length != 2 || pos[0].to_i < 0 || pos[0].to_i > width-1 || pos[1].to_i < 0 || pos[1].to_i > height-1
      puts "INVALID MOVE"
      return get_move
    end

    move(pos)
  end

  def move(pos)
    x = pos[0].to_i
    y = pos[1].to_i
    if board[x][y] == "X"
      game_over
    end
    @hidden[x.to_s + " " + y.to_s] = false if board[x][y] != "0"
    show_adjacents(pos) if board[x][y] == "0"
  end

  def game_over
    display(false)
    puts "GAME OVER"
    @over = true
  end

  def won?
    0.upto(width-1) do |i|
      0.upto(height-1) do |j|
        if hidden[i.to_s + " " + j.to_s] && board[i][j] != "X"
          return false
        end
      end
    end
    @over = true
  end

  def show_adjacents(pos)
    x = pos[0].to_i
    y = pos[1].to_i

    return if hidden[x.to_s + " " + y.to_s] == false || x < 0 || y < 0 || x >= width || y >= height
    
    @hidden[x.to_s + " " + y.to_s] = false

    return if board[x][y].to_i > 0

    show_adjacents([x-1, y-1])
    show_adjacents([x-1, y])
    show_adjacents([x-1, y+1])

    show_adjacents([x, y-1])
    show_adjacents([x, y+1])
    
    show_adjacents([x+1, y-1])
    show_adjacents([x+1, y])
    show_adjacents([x+1, y+1])
  end
end

if __FILE__ == $PROGRAM_NAME
  puts "WELCOME TO MINESWEEPER"
  puts "BOARD SIZE IS 10 X 10"
  print "HOW MANY MINES? (10 easy, 15 medium, 20 hard):  "
  mines = gets.chomp.to_i
  m = Minesweeper.new(10, 10, mines)
  m.step
end