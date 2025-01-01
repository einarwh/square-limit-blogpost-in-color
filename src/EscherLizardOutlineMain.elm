module EscherLizardOutlineMain exposing (..)

import Box exposing (..)
import Lens exposing (..)
import Picture exposing (..)
import FishOutline exposing (fishOutlineShapes)
import LizardOutline exposing (lizardOutlineShapes)
import Fitting exposing (createPicture)
import Html exposing (Html)
import Decor exposing (render, decorate)
import Rendering exposing (toSvg, toSvgWithBoxes)

main : Html msg
main = 
  let 
    box1 = { a = { x = 50.0, y = 59.0 }
           , b = { x = 152.0, y = 0.0 }
           , c = { x = 0.0, y = 152.0 } }
    lens1 = (box1, Blackish)
    p = createPicture lizardOutlineShapes
    w = 250 
    h = 250
    bounds = (w, h)
    vb = { x = 0, y = 0, width = w, height = h }
    boxes = []
  in     
    lens1 
    |> p 
    |> toSvgWithBoxes vb bounds boxes
    |> decorate  
 