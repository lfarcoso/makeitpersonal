class PlaylistsController < ApplicationController
  def new
    @playlist = Playlist.new
  end

  def fetch
    @playlist = Playlist.new(params[:playlist])
    @playlist.fetch
    respond_to do |format|
      format.html { render @playlist }
    end
  end
end
