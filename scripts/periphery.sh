#!/bin/bash

mise exec -- periphery scan \
    --project VanessaGames/VanessaGames.xcworkspace \
    --schemes ClausyTheCloud \
    --schemes SharedGameEngine \
    --schemes SharedAssets \
    --relative-results \
    --report-exclude "**/Derived/*.swift"
