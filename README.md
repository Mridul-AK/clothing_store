# Threadline: Flutter Clothing Store

Threadline is an e-commerce app for a clothing brand, built with Flutter. It is
structured with **Clean Architecture** and uses **BLoC** (`flutter_bloc`) with
explicit events and states.

The app covers five modules:

| Module | What it does |
| --- | --- |
| Login | Email and password form with live validation and dummy authentication. |
| Product listing | 10 clothing products loaded from a local JSON file. |
| Watchlist | Save and remove favourite products. The heart icon stays in sync on every screen. |
| Shopping cart | Add, remove and change quantities, with a live total and item count. |
| Dummy payment | Checkout summary, a simulated payment, then a success screen with a generated order ID. |

There is no backend, no database and no real payment gateway. Product data
comes from a bundled JSON asset. The cart and the watchlist are kept in memory
for the session.

---

## Demo

- **Demo account:** `demo@threadline.com` / `Demo@123`. These credentials are
  also shown on the login screen.
- **Screen recording:** <!-- add the link to the demo recording here -->

---

## Getting started

### Requirements

| Tool | Version |
| --- | --- |
| Flutter | 3.32 or newer (developed on 3.44.1, stable channel) |
| Dart | 3.8 or newer |
| Android Studio or VS Code | with the Flutter plugin |
| A device | an Android emulator, an iOS simulator or a physical device |

Run `flutter doctor` to check your setup.

### Run the app

```bash
git clone <repository-url>
cd clothing_store
flutter pub get
flutter run
```

Product images load over the network. With no internet connection, the cards
show a placeholder icon instead and everything else keeps working.

### Run the tests and the analyzer

```bash
flutter test
flutter analyze
```

### Build a release APK

```bash
flutter build apk --release
```

---

## Architecture

The code is organised **by feature**. Each feature is split into three layers,
and dependencies only point inwards, from presentation to domain. The data
layer implements interfaces that the domain layer defines, so the domain never
depends on Flutter, JSON or storage details.

```
Presentation layer      pages, widgets
        │  dispatches events / renders states
        ▼
BLoC                    events → states
        │  calls
        ▼
Use cases               one business operation each
        │  depends on
        ▼
Repository interfaces   (domain layer)
        ▲  implemented by
        │
Repository impls        (data layer) catch exceptions, return Result<T>
        │  use
        ▼
Local data sources      JSON asset / in-memory maps / dummy gateway
```

### Folder structure

```
lib/
├── main.dart                     # entry point
├── app.dart                      # MaterialApp + app-wide BlocProviders
├── injection_container.dart      # get_it wiring (the only place that knows concrete classes)
├── core/
│   ├── constants/                # app name, demo credentials
│   ├── error/                    # exceptions, failures, Result<T> (Ok / Err)
│   ├── router/                   # named routes, per-route BLoC scoping
│   ├── theme/                    # Material 3 light and dark themes
│   ├── usecase/                  # UseCase<T, Params> contract, NoParams
│   ├── utils/                    # price and date formatting, cents maths
│   └── widgets/                  # reusable widgets (state views, stepper, total bar, image)
└── features/
    ├── auth/        data / domain / presentation
    ├── products/    data / domain / presentation
    ├── watchlist/   data / domain / presentation
    ├── cart/        data / domain / presentation
    ├── payment/     data / domain / presentation
    └── home/        presentation (bottom navigation shell)
```

### Layer responsibilities

**Presentation**
- Contains the screens and the reusable widgets.
- `ProductCard`, `ProductGrid`, `CartItemTile`, `QuantityStepper`, `TotalBar`,
  `LoadingView`, `EmptyStateView` and `ErrorStateView` are shared across screens.
- Widgets only dispatch events and render states. They contain no business
  rules.
- `ProductCard` knows nothing about BLoCs. It receives its data and callbacks
  from `ProductGrid`.

**BLoC**
- Translates events into use-case calls, and translates results into states.

**Domain**
- **Entities:** `Product`, `Cart`, `CartItem`, `User`, `PaymentReceipt`.
- **Repository interfaces.**
- **Use cases**, which hold the business rules:
  - Adding a product that is already in the cart increases its quantity instead
    of adding a second line.
  - Setting a quantity below 1 removes the line.
  - A product can have at most 10 units in the cart.
  - The watchlist never holds duplicates.
  - Payment is refused when the cart is empty.
  - The amount charged is read from the cart, never from the UI.
- **`CredentialsValidator`** is shared by the use case and the BLoC, so both
  apply exactly the same login rules.

**Data**
- **Models:** `ProductModel` and `UserModel` handle JSON parsing with strict
  types.
- **Data sources:** they throw typed exceptions.
- **Repository implementations:** they catch those exceptions and return a
  `Result<T>`, which is either `Ok(value)` or `Err(Failure)`. No layer above the
  repositories needs a `try`/`catch`.

### Error handling

| Kind | Raised by | Example |
| --- | --- | --- |
| `AppException` | data sources | `AuthException`, `DataSourceException`, `PaymentException` |
| `Failure` | repositories and use cases | `ValidationFailure`, `AuthFailure`, `DataFailure`, `CartFailure`, `PaymentFailure` |

A failure becomes an error state. Depending on the case, that state is shown
as one of the following:
- a full-screen error view with a **Try again** button,
- an inline banner (wrong credentials on the login screen),
- a snackbar (cart limit reached, payment rejected).

### Dependency injection and BLoC scoping

`get_it` registers the following:
- **Data sources, repositories and use cases** are lazy singletons. The
  in-memory stores are the session state, so there must be only one of each.
- **BLoCs** are factories.

Where each BLoC is provided:
- **`ProductsBloc`, `WatchlistBloc` and `CartBloc`** are provided once, above
  `MaterialApp`, so every route reads the same instance. This keeps the
  favourite icon and the cart count in sync between the catalogue, the
  watchlist, the cart and checkout.
- **`LoginBloc` and `PaymentBloc`** are scoped to their route, so each visit
  starts in a clean state.

### Navigation

| Route | Screen |
| --- | --- |
| `/` | Login |
| `/home` | Bottom navigation: Shop · Watchlist · Cart. Badges show the watchlist and cart counts. |
| `/checkout` | Order summary and the **Pay now** button. |
| `/payment-success` | Order ID, amount paid, item count and date. |

How the user moves between them:
1. A successful login replaces the login route with `/home`.
2. A successful payment replaces checkout with `/payment-success`.
3. **Continue shopping** (or the back button) on the success screen clears the
   stack back to `/home`.

---

## BLoCs: events and states

### LoginBloc (`features/auth`)

| Event | Effect |
| --- | --- |
| `LoginEmailChanged(email)` | Updates the email and its live validation error. |
| `LoginPasswordChanged(password)` | Updates the password and its live validation error. |
| `LoginSubmitted()` | Validates the form, then calls `LoginUseCase`. Uses `droppable()`, so a double tap sends only one request. |

**State:** `LoginState` holds `email`, `password`, `emailError`,
`passwordError`, `status` (`initial` · `submitting` · `success` · `failure`),
`errorMessage` and `user`.

`canSubmit` is true only when both fields are valid and no request is in
flight. It is what enables the **Log in** button.

### ProductsBloc (`features/products`)

| Event | Effect |
| --- | --- |
| `LoadProducts()` | Loads the catalogue. It is also used for retry and pull-to-refresh, and uses `restartable()`. |

**States:** `ProductsInitial` · `ProductsLoading` · `ProductsLoaded(products)` ·
`ProductsEmpty` · `ProductsError(message)`.

### WatchlistBloc (`features/watchlist`)

| Event | Effect |
| --- | --- |
| `LoadWatchlist()` | Reads the saved products. |
| `AddToWatchlist(product)` | Saves a product. Saving one that is already saved does nothing. |
| `RemoveFromWatchlist(productId)` | Removes a product. |
| `ToggleWatchlist(product)` | Used by the heart icon: adds the product when absent, removes it when present. |

**State:** `WatchlistState` holds `status` (`initial` · `loading` · `success` ·
`empty` · `failure`), `items` and `errorMessage`.

Events are processed with `sequential()`, so rapid taps are applied in order.

### CartBloc (`features/cart`)

| Event | Effect |
| --- | --- |
| `LoadCart()` | Reads the cart. |
| `AddToCart(product)` | Adds one unit, or increases the quantity if the product is already in the cart. |
| `RemoveFromCart(productId)` | Removes the whole line. |
| `IncreaseQuantity(productId)` | Adds 1 to the quantity, up to 10. |
| `DecreaseQuantity(productId)` | Subtracts 1. At quantity 1, the line is removed. |
| `ClearCart()` | Empties the cart, after a confirmation dialog. |

**State:** `CartState` holds the following:
- `status`: `initial` · `loading` · `success` · `empty` · `failure`.
- `cart`: a `Cart` entity that exposes `totalItems` and `totalAmount`.
- `errorMessage`.
- `notice`: a one-shot info or error message that the UI shows as a snackbar.

Totals are calculated in the `Cart` entity, not in widgets. They are summed in
whole cents to avoid floating-point drift.

### PaymentBloc (`features/payment`)

| Event | Effect |
| --- | --- |
| `InitiatePayment()` | Runs the simulated payment. Uses `droppable()`, so a double tap can never charge twice. |

**States:** `PaymentInitial` · `PaymentProcessing` ·
`PaymentSuccess(receipt)` · `PaymentError(message)`.

While the payment is processing, the **Pay now** button shows a spinner and the
back button is blocked.

---

## Use cases

Every use case implements `UseCase<T, Params>`: it has a single `call()` and
returns `Future<Result<T>>`.

| Feature | Use case | Responsibility |
| --- | --- | --- |
| Auth | `LoginUseCase` | Validates the email format and password length, normalises the email, then authenticates against the predefined account. |
| Products | `GetProductsUseCase` | Returns the catalogue parsed from `assets/data/products.json`. |
| Watchlist | `GetWatchlistUseCase` | Returns the saved products. |
| | `AddToWatchlistUseCase` | Saves a product, ignoring duplicates. |
| | `RemoveFromWatchlistUseCase` | Removes a product by id. |
| Cart | `GetCartUseCase` | Returns the current `Cart`. |
| | `AddToCartUseCase` | Adds one unit, merges with an existing line, and enforces the 10-unit limit. |
| | `RemoveFromCartUseCase` | Removes a line. |
| | `UpdateCartQuantityUseCase` | Sets a quantity. A quantity of 0 or less removes the line; more than 10 is rejected. |
| | `ClearCartUseCase` | Empties the cart. |
| Payment | `ProcessDummyPaymentUseCase` | Reads the cart total, charges the dummy gateway, returns a receipt with a generated order ID such as `ORD-20261017-7K3QX9`, then clears the cart. |

---

## Data

- **Products:** `assets/data/products.json` contains 10 clothing products.

  Each product has the following fields, which are parsed into a strongly
  typed `ProductModel`:
  - `id`
  - `name`
  - `subtitle`
  - `price`
  - `image_url`
  - `category`

  A missing or wrongly typed field makes the whole catalogue report as
  malformed, which shows the error state instead of a half-filled card.
- **Cart and watchlist:** stored in in-memory maps keyed by product id
  (`InMemoryCartDataSource`, `InMemoryWatchlistDataSource`). They reset when
  the app restarts.
- **Authentication:** `AuthLocalDataSourceImpl` checks the credentials against
  a predefined account.
- **Payment:** `DummyPaymentGateway` waits 2 seconds, then approves any
  positive amount.

The data sources add a short artificial delay so that the loading states are
visible in the demo.

---

## Tests

48 tests in `test/`. They cover business logic, BLoCs and parsing.

| File | Covers |
| --- | --- |
| `auth/credentials_validator_test.dart` | Email format and password rules. |
| `auth/login_usecase_test.dart` | Validation runs before authentication; the email is normalised; wrong credentials fail. |
| `auth/login_bloc_test.dart` | Field errors, the submit flow, success and failure states. |
| `auth/login_page_test.dart` | The login button is enabled only when both fields are valid. |
| `products/product_local_data_source_test.dart` | JSON parses into at least 10 typed products; malformed or missing JSON maps to `DataSourceException`. |
| `products/products_bloc_test.dart` | The loading → loaded, empty and error sequences. |
| `watchlist/watchlist_bloc_test.dart` | Add, remove, toggle, no duplicates, and the empty state. |
| `cart/cart_test.dart` | Calculation of the total amount and the item count. |
| `cart/cart_usecases_test.dart` | Add, merge, quantity limits and removing at quantity 0. |
| `cart/cart_bloc_test.dart` | Cart events → states, including notices. |
| `payment/payment_test.dart` | Charges the cart total, clears the cart, and refuses an empty cart. |

Shared fixtures are in `test/helpers/fixtures.dart`.

---

## Packages

| Package | Purpose |
| --- | --- |
| `flutter_bloc` | BLoC state management. |
| `bloc_concurrency` | `droppable`, `restartable` and `sequential` event transformers. |
| `equatable` | Value equality for entities, events and states. |
| `get_it` | Dependency injection. |
| `bloc_test`, `mocktail` (dev) | BLoC and use-case tests. |
