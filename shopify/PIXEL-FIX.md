# Meta Pixel fix

## What was wrong

Your `layout/theme.liquid` head had three problems:

1. **Two pixels installed** — `1763779941048884` and `2026704144426783`. Both were initialised, both fired `PageView`. Your Events Manager was seeing double traffic split across two assets, and any ad optimising on one was blind to half the signal.
2. **`AddToCart` fired on every pageview.** A bare `fbq('track','AddToCart')` sat between the two blocks with no condition and no product data. Every visit to every page — homepage, blog, policies — counted as an add to cart. Your AddToCart number is not a real number and should not be trusted for anything historical.
3. **No product data on the event.** Even when a real add happened, the event carried no `content_ids`, so it could not be matched to a catalogue item.

## What the fixed file does

`theme.liquid` in this folder now has one pixel block. The ID sits on its own line at the top:

```liquid
{%- assign meta_pixel_id = '1763779941048884' -%}
```

Change that one string if you are keeping the other pixel instead. It feeds both the script and the `<noscript>` fallback, so they can no longer drift apart.

`AddToCart` is now bound to actual submissions of any `/cart/add` form and sends `content_ids` and `num_items` with it.

## Which pixel is set

**`1763779941048884`** — confirmed, and already the value on the assign line. Nothing to change.

The other pixel, `2026704144426783`, no longer loads. Before you delete that data source in Events Manager, check that no active campaign still references it — if one does, point it at the 8884 pixel first, then remove the old source. Historical data on the retired pixel stays in Events Manager either way; you just won't collect anything new to it.

## Installing

1. **Online Store → Themes → ⋯ → Duplicate** first. Always.
2. On the copy: **⋯ → Edit code → `layout/theme.liquid`**.
3. Select all, paste in the contents of this folder's `theme.liquid`, save.
4. Install the **Meta Pixel Helper** Chrome extension, load your storefront, and confirm: one pixel, one PageView, no AddToCart.
5. Add a product to cart. Confirm one AddToCart fires, with a content ID.
6. Preview the rest of the store, then publish.

## Note on expected numbers

Once this is live your AddToCart count will drop sharply, because it will finally only be counting adds to cart. That is the fix working. Any ad set optimising for AddToCart has been training on noise and will need a fresh learning period.
