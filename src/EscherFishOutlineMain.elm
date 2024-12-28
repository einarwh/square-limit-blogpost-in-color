module EscherFishOutlineMain exposing (..)

import Box exposing (..)
import Lens exposing (..)
import Picture exposing (..)
import FishOutline exposing (fishOutlineShapes)
import Fitting exposing (createPicture)
import Html exposing (Html)
import Decor exposing (render, decorate)
import Rendering exposing (toSvg, toSvgWithBoxes)

main : Html msg
main = 
  let 
    box1 = { a = { x = 50.0, y = 25.0 }
           , b = { x = 200.0, y = 0.0 }
           , c = { x = 0.0, y = 200.0 } }
    lens1 = (box1, Blackish)
    fish = createPicture fishOutlineShapes
    w = 250 
    h = 250
    bounds = (w, h)
    vb = { x = 0, y = 0, width = w, height = h }
    boxes = []
  in     
    lens1 
    |> fish 
    |> toSvgWithBoxes vb bounds boxes
    |> decorate  
 