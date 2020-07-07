import UIKit

class PokemonCell: UICollectionViewCell {
  
  @IBOutlet weak var pokemonImage: UIImageView!
  @IBOutlet weak var pokemonText: UILabel!
  
  func configure(pokemon: Pokemon) {
    pokemonText.text = pokemon.pokemonName
    pokemonImage.image = pokemon.image    

  }
}
