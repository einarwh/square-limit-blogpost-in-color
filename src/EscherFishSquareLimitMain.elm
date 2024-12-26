module EscherFishSquareLimitMain exposing (..)

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
    box = { a = { x = 0.0, y = 0.0 }
          , b = { x = 400.0, y = 0.0 }
          , c = { x = 0.0, y = 400.0 } }
    lens = (box, Blackish)
    fish = createPicture fishShapes
    fishes = lens |> squareLimit 5 fish 
    w = 400 
    h = 400
    bounds = (w, h)
    vb = { x = 0, y = 0, width = w, height = h }
    boxes = []
  in     
    fishes 
    |> toSvgWithBoxes vb bounds boxes
    |> decorate  
 