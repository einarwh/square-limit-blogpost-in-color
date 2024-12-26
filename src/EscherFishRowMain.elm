module EscherFishRowMain exposing (main)

import Box exposing (..)
import Lens exposing (..)
import Picture exposing (..)
import Fish exposing (fishShapes)
import Fitting exposing (createPicture)
import Html exposing (Html)
import Decor exposing (render, decorate)
import Rendering exposing (toSvg, toSvgWithBoxes)

main : Html msg
main = 
  let 
    box1 = { a = { x = 100.0, y = 0.0 }
           , b = { x = 200.0, y = 0.0 }
           , c = { x = 0.0, y = 200.0 } }
    box2 = { a = { x = 350.0, y = 0.0 }
           , b = { x = 200.0, y = 0.0 }
           , c = { x = 0.0, y = 200.0 } }
    box3 = { a = { x = 600.0, y = 0.0 }
           , b = { x = 200.0, y = 0.0 }
           , c = { x = 0.0, y = 200.0 } }
    lens1 = (box1, Whiteish)
    lens2 = (box2, Greyish)
    lens3 = (box3, Blackish)
    fish = createPicture fishShapes
    fish1 = lens1 |> fish 
    fish2 = lens2 |> fish 
    fish3 = lens3 |> fish 
    fishes = fish1 ++ fish2 ++ fish3
    w = 750 
    h = 200
    bounds = (w, h)
    vb = { x = 50, y = 0, width = w, height = h }
    boxes = []
  in     
    fishes 
    |> toSvgWithBoxes vb bounds boxes
    |> decorate  
 