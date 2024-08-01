class PokemonPokedex_Scene

  def OpenSearchBox()
    on_input = lambda {|text, char=""| searchByName(text, char) }
    term = pbMessageFreeTextWithOnInput(_INTL("¿Qué Pokémon desea buscar?"), "", false, 32, width = 240, on_input = on_input)
    return false if term == "" || term == nil
    searchByName(term)
  end

  def searchByName(text, char="")
    echoln("Searching for #{text}...")
    current_index = @sprites["pokedex"].index
    for i in current_index...@dexlist.length
      item = @dexlist[i]
      next if !$player.seen?(item[:species])
      next if item[:shift] && !$player.seen?(item[:species])
      return pbRefreshDexList(item[:number] - 1) if item[:name].downcase.include?(text.downcase)
    end
    if current_index > 0
      for i in 0...current_index
        item = @dexlist[i]
        next if !$player.seen?(item[:species])
        next if item[:shift] && !$player.seen?(item[:species])
        return pbRefreshDexList(item[:number] - 1) if item[:name].downcase.include?(text.downcase)
      end
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
        elsif Input.trigger?(Input::SPECIAL)
          OpenSearchBox()
        end
      end
    end
  end
end