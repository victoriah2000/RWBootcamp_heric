

import UIKit

class CompactViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  let pokemons = PokemonGenerator.shared.generatePokemons()

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pokemons.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
    let pokemon = pokemons[indexPath.row]
    cell.configure(pokemon: pokemon)
    return cell
  }
  
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.backgroundColor = .clear
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  //: MARK -- Layout
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let numberOfItemsPerRow: CGFloat = 3
    let interItemSpacing: CGFloat = 10
    
    let maxWidth = UIScreen.main.bounds.width
    let totalSpacing = interItemSpacing * numberOfItemsPerRow
    let itemWidth = (maxWidth - totalSpacing)/numberOfItemsPerRow

    return CGSize(width: itemWidth, height: itemWidth)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }
}
