class SongsController < ApplicationController
  def index
    p = Preference.last
    if params[:artist_id]
      @artist = Artist.find_by(id: params[:artist_id])
      if @artist.nil?
        redirect_to artists_path, alert: "Artist not found"
      else
        p = Preference.first_or_create(song_sort_order: "")
        p.song_sort_order = "ASC" if p.song_sort_order.empty?
        @songs = @artist.songs.order(:title => p.song_sort_order)
      end
    else
      p = Preference.first_or_create(song_sort_order: "")
      p.song_sort_order = "ASC" if p.song_sort_order.empty?
      @songs = Song.all.order(:title => p.song_sort_order)
    end
  end

  def show
    if params[:artist_id]
      @artist = Artist.find_by(id: params[:artist_id])
      @song = @artist.songs.find_by(id: params[:id])
      if @song.nil?
        redirect_to artist_songs_path(@artist), alert: "Song not found"
      end
    else
      @song = Song.find(params[:id])
    end
  end

  def new
    if Preference.last.allow_create_songs
      @song = Song.new
    else
      redirect_to songs_path, alert: "No new songs allowed."
    end
  end

  def create
    @song = Song.new(song_params)

    if @song.save
      redirect_to @song
    else
      render :new
    end
  end

  def edit
    @song = Song.find(params[:id])
  end

  def update
    @song = Song.find(params[:id])

    @song.update(song_params)

    if @song.save
      redirect_to @song
    else
      render :edit
    end
  end

  def destroy
    @song = Song.find(params[:id])
    @song.destroy
    flash[:notice] = "Song deleted."
    redirect_to songs_path
  end

  private

  def song_params
    params.require(:song).permit(:title, :artist_name)
  end
end

