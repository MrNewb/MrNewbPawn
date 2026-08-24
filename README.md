# MrNewbPawn

Pawn shops with optional buy-back of sold stock, plus smelter zones.

[Documentation](https://mrnewb.github.io/docs/mrnewbpawn) · [GitHub](https://github.com/MrNewb/MrNewbPawn) · [Discord](https://discord.gg/mrnewbscripts)

## Install

Needs [ox_lib](https://github.com/overextended/ox_lib) and [Newb_Bridge](https://github.com/MrNewb/Newb_Bridge).

```cfg
ensure ox_lib
ensure Newb_Bridge
ensure MrNewbPawn
```

## Config

`configs/config.lua` — shop locations, sell lists, hours, `PurchaseStock` / `PurchaseMarkup`, foundry positions, melt recipes.

Item names and PNGs: `[INSTALL]/images/` (not usable items). Copy into your inventory images folder.

Sold stock is in-memory per shop until the resource restarts.
