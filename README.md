# Project Name

A modern iOS app demonstrating UICollectionView with horizontal pagination and dynamic image loading from Picsum Photos API.
# Preview
<img src="https://github.com/user-attachments/assets/db6cf820-33b7-44e9-b5b8-b09d8045b626" width="300" height="600" />


## 1. Libraries Used

- **Combine**: Used for downloading and caching images asynchronously.

## 2. Technology
- **Async Let**: To fetch multiple users concurrently using async let
- **Async await**: modern concurrency
- **XCTestCase**
- **UIKit**
- **Core Data**
- **Combine**
- **NSCache**
## 3. Architecture
<img width="540" height="213" alt="image" src="https://github.com/user-attachments/assets/3180a24a-415d-433a-8bbe-d8b970a3457c" />

[For details about architecture, please visit this](https://benoitpasquier.com/ios-swift-mvvm-pattern/)
### Why MVVM?
We chose **MVVM (Model-View-ViewModel)** because:

- 🚀 **Fast development**: Simple and lightweight, allowing us to implement features quickly.  
- 🌍 **Popular**: Widely adopted in the iOS community, with strong support and resources available.  
- 🧪 **Easy unit testing**: Business logic is separated into the ViewModel, making testing straightforward without relying on UI components.  

This makes MVVM a practical choice where both **development speed** and **code quality** are priorities.



## 4. Setup and Installation

1. Clone this repository to your local machine.
   ```bash
   git clone https://github.com/hiepcute/ImageGalary.git

