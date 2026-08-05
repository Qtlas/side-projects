# Algorithmique en C


## Structure du dépôt

```
algoEnC/
├── TD/
│   ├── TD7-piles-files-arbres/          # piles, files, parcours d'arbres, NPI
│   └── TD8-arbres-binaires-recherche/   # arbres binaires de recherche (ABR)
└── TP/
    ├── TP3-listes-chainees-lexique/     # lexique en liste chaînée triée
    └── TP4-abr-lexique-jaccard/         # lexique en ABR + indice de Jaccard
```

Chaque dossier contient son propre `README.md` détaillant son contenu, un
`Makefile` pour la compilation, et les énoncés/corrigés/rapports au format
PDF lorsqu'ils sont disponibles.

| Dossier | Sujet | Concepts clés |
|---|---|---|
| [`TD/TD7-piles-files-arbres`](TD/TD7-piles-files-arbres) | Piles, files et arbres | Pile (LIFO), file circulaire (FIFO), parcours préfixe/infixe/postfixe itératifs, notation polonaise inversée |
| [`TD/TD8-arbres-binaires-recherche`](TD/TD8-arbres-binaires-recherche) | ABR | Insertion, recherche, min/max, complexité en fonction de la hauteur |
| [`TP/TP3-listes-chainees-lexique`](TP/TP3-listes-chainees-lexique) | Lexique (liste chaînée) | Liste chaînée triée, fusion, import de fichier |
| [`TP/TP4-abr-lexique-jaccard`](TP/TP4-abr-lexique-jaccard) | Lexique (ABR) | ABR, équilibrage, transformation arbre → liste, indice de Jaccard |

## Compilation

Chaque projet dispose de son propre `Makefile`. Depuis le dossier d'un
projet :

```sh
make        # compile le(s) exécutable(s)
make run    # compile (si nécessaire) puis exécute (TP3, TP4, TD8)
make clean  # supprime les exécutables générés
```

### Prérequis

- `gcc`
- `make`

Tous les programmes ont été testés avec `gcc -Wall -Wextra -std=c11` sans
avertissement.
