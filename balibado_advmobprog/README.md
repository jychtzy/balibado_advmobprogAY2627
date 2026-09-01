# A-j B. Balibado

## INF231

## CTADMOBL - Advance Mobile Programming

A flutter project that focusesnon advance project. Covering the Mobile to Web Transactions.

## Lab Activity Instance

## Lab Activity 1: setState() is used for temporary, single-screen data (ephemeral state), such as the counter that resets to 0 when the page reloads. Conversely, Provider is used for persistent, app-wide data (app state), such as the light/dark theme that remains consistent across all screens.

## Lab Activity 2: Each part only does its own job. The screen doesn't know how the data was fetched. The service doesn't know how it will be displayed. That separation makes the app easier to fix and easier to test.

## Lab Activity 3: The CartService fetches API data mapped into Cart models for the CartScreen. Tapping a product executes a getById request (/products/{id}) to load specific details before pushing the ProductDetailsScreen. The updated local state pattern updates cart items in-memory and recalculates totals instantly for real-time UI responsiveness. Meanwhile, using getById at a cart endpoint (e.g., /cart/5) targets a specific resource identifier directly, optimizing efficiency and reducing payload size.

## Lab Acivity 4: The User model defines the shape of user data and converts it between JSON and Dart objects using fromJson() and toJson(). The UserService handles the actual work — it calls the login API, turns the response into a User object using the model, and saves it to SharedPreferences. ProfileScreen never talks to the API directly; it simply calls UserService.getUser(), which reads the saved data and converts it back into a User, and the screen displays whatever it receives through a FutureBuilder. This setup follows a layered design similar to MVC or the Repository pattern: the Model shapes the data, the Service fetches and stores it, and the Screen only displays it. Each layer depends only on the one below it, so the UI never handles JSON or storage directly, making the app easier to maintain and change. This same pattern applies to CartScreen. Since UserService.getUser() already gives the logged-in user's id, CartScreen can use that id to call a CartService method like getCartForUser(user.id) to fetch only that user's cart items. The saved user becomes the single source of truth for identifying who is logged in, so any screen needing user-specific data can just get the user first, then use their id to load what it needs.