class PokemonPokedex_Scene

  def searchByName()
    term = pbMessageFreeText(_INTL("¿Qué Pokémon desea buscar?"), "", false, 32)
    return false if term == "" || term == nil
    @dexlist.each do |item|
      next if !$player.seen?(item[:species])
      next if item[:shift] && !$player.seen?(item[:species])
      return pbRefreshDexList(item[:number] - 1) if item[:name].downcase.include?(term.downcase)
    end
    return false
  end

  def pbPokedex
    pbActivateWindow(@sprites, "pokedex") do
      loop do
        Graphics.update
        Input.update
        oldindex = @sprites["pokedex"].index
        pbUpdate
        if oldindex != @sprites["pokedex"].index
          $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index if !@searchResults
          pbRefresh
        end
        if Input.trigger?(Input::ACTION)
          pbSEPlay("GUI pokedex open")
          @sprites["pokedex"].active = false
          pbDexSearch
          @sprites["pokedex"].active = true
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          if @searchResults
            pbCloseSearch
          else
            break
          end
        elsif Input.trigger?(Input::USE)
          if $player.seen?(@sprites["pokedex"].species)
            pbSEPlay("GUI pokedex open")
            pbDexEntry(@sprites["pokedex"].index)
          end
        elsif Input.triggerex?(:F)
          searchByName()
        end
      end
    end
  end
end