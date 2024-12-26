module EscherFishTtilesMain exposing (..)

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
    box2 = { a = { x = 375.0, y = 0.0 }
           , b = { x = 200.0, y = 0.0 }
           , c = { x = 0.0, y = 200.0 } }
    lens1 = (box1, Blackish)
    lens2 = (box2, Blackish)
    fish = createPicture fishShapes
    fish1 = lens1 |> ttile1 fish 
    fish2 = lens2 |> ttile2 fish 
    fishes = fish1 ++ fish2 
    w = 550 
    h = 225
    bounds = (w, h)
    vb = { x = 50, y = 0, width = w, height = h }
    boxes = []
  in     
    fishes 
    |> toSvgWithBoxes vb bounds boxes
    |> decorate  
 