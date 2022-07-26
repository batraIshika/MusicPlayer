require "rubygems"
require "gosu"

TOP_COLOR = Gosu::Color.new(0xff_88ddaa)
BOTTOM_COLOR = Gosu::Color.new(0xff_88ddaa)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ["Null", "Pop", "Classic", "Jazz", "Rock"]

class ArtWork
  attr_accessor :bmp

  def initialize(file)
    @bmp = Gosu::Image.new(file)
  end
end

class Track
  attr_accessor :musicid, :name, :location

  def initialize(musicid, name, location)
    @musicid = musicid
    @name = name
    @location = location
  end
end

class Album
  attr_accessor :title, :artist, :artwork, :genre, :tracks

  def initialize(title, artist, artwork, genre, tracks)
    @title = title
    @artist = artist
    @artwork = artwork
    @genre = genre
    @tracks = tracks
  end
end

class Song
  attr_accessor :song

  def initialize
    @song = Gosu::Song.new(file)
  end
end

# Record definition will be here

class MusicPlayerMain < Gosu::Window
  def initialize
    super 1000, 600
    self.caption = "GUI MUSIC PLAYERRRRRR"
    @loct = [60, 60]
    @font = Gosu::Font.new(30)
    @c = 0
  end
   # Draws the artwork on the screen for all the albums

   def draw_album(alb)
    @bmp = Gosu::Image.new(alb.artwork)
    @bmp.draw(60, 25, z = ZOrder::PLAYER)
  end
 # Detects a 'mouse sensitive' area 
  # i.e either an album or a track. returns true or false

  def area_clicked(mouse_x, mouse_y)
    if ((mouse_x > 60 && mouse_x < 940) && (mouse_y > 25 && mouse_y < 295))
      @c = 1
      playTrack(@c)
    end
  end
  # Draw a coloured background 

  def draw_background
    draw_quad(0, 0, TOP_COLOR, 0, 600, TOP_COLOR, 1000, 0, BOTTOM_COLOR, 1000, 600, BOTTOM_COLOR, z = ZOrder::BACKGROUND)
  end


  # Put in your code here to load albums and tracks

  def load_album()
    def read_track(music_file, input)
      music_id = input
      track_name = music_file.gets
      track_location = music_file.gets.chomp
      track = Track.new(music_id, track_name, track_location)
      return track
    end

    def read_tracks(music_file)
      count = music_file.gets.to_i
      tracks = Array.new()
      index = 0
      while index < count
        track = read_track(music_file, index + 1)
        tracks << track
        index += 1
      end
      tracks
    end

    def read_album(music_file)
      album_title = music_file.gets.chomp
      album_artist = music_file.gets
      album_artwork = music_file.gets.chomp
      album_genre = music_file.gets.to_i
      album_tracks = read_tracks(music_file)
      album = Album.new(album_title, album_artist, album_artwork, album_genre, album_tracks)
      return album
    end

    music_file = File.new("songss.txt", "r")
    album = read_album(music_file)
    return album
  end

 
 

  # Takes a track index and an Album and plays the Track from the Album
  def playTrack(track)
    album = load_album()
    index = 0
    while index < album.tracks.length
      if (album.tracks[index].musicid == track)
        @song = Gosu::Song.new(album.tracks[index].location)
        @song.play(false)
      end
      index += 1
    end
  end

  
  # Not used? Everything depends on mouse actions.

  def update
    if (@song)
      if (!@song.playing?)
        @c += 1
        playTrack(@c)
      end
    end
  end

  # Draws the album images and the track list for the selected album

  def draw
    album = load_album
    index = 0
    xcord = 300
    ycord = 250
    draw_background
    draw_album(album)
    if (!@song)
      @font.draw_text("#{album.title}", xcord, 350, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLACK)
      @font.draw_text("Number of tracks : #{album.tracks.length}", xcord, 400, ZOrder::UI, 1.5, 1.5, Gosu::Color::BLACK)
    else
      while (index < album.tracks.length)
        @font.draw_text("#{album.tracks[index].name}", xcord + 70, ycord +=60, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
        if (album.tracks[index].musicid == @c)
          @font.draw_text("~", xcord +50 , ycord, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
        end
        index = index + 1
      end
    end
  end

  def needs_cursor?; true; end

  # If the button area (rectangle) has been clicked on change the background color
  # also store the mouse_x and mouse_y attributes that we 'inherit' from Gosu
  # you will learn about inheritance in the OOP unit - for now just accept that
  # these are available and filled with the latest x and y locations of the mouse click.
  def button_down(id)
    case id
    when (Gosu::MsLeft)
      @loct = [mouse_x, mouse_y]
      area_clicked(mouse_x, mouse_y)
    end
  end
end

# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0
