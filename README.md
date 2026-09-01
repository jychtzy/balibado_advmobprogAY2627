# A-j B. Balibado

## INF231

## CTADMOBL - Advance Mobile Programming

A flutter project that focusesnon advance project. Covering the Mobile to Web Transactions.

## Lab Activity Instance

## Lab Activity 1: setState() is used for temporary, single-screen data (ephemeral state), such as the counter that resets to 0 when the page reloads. Conversely, Provider is used for persistent, app-wide data (app state), such as the light/dark theme that remains consistent across all screens.

## Lab Activity 2: Each part only does its own job. The screen doesn't know how the data was fetched. The service doesn't know how it will be displayed. That separation makes the app easier to fix and easier to test.

## Lab Activity 3: The CartService fetches API data mapped into Cart models for the CartScreen. Tapping a product executes a getById request (/products/{id}) to load specific details before pushing the ProductDetailsScreen. The updated local state pattern updates cart items in-memory and recalculates totals instantly for real-time UI responsiveness. Meanwhile, using getById at a cart endpoint (e.g., /cart/5) targets a specific resource identifier directly, optimizing efficiency and reducing payload size.
