module Rendering exposing (toSvg, toSvgWithBoxes)

import Vector exposing (..)
import Shape exposing (..)
import Style exposing (..)
import Box exposing (..)
import Picture exposing (..)
import Mirror exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html.Attributes

type alias ViewBox =
  { x : Int 
  , y : Int 
  , width : Int 
  , height : Int }

toString : Float -> String 
toString = String.fromFloat

f2s : Float -> String 
f2s = String.fromFloat

i2s : Int -> String 
i2s = String.fromInt

getStrokeWidthFromStyle : Maybe StrokeStyle -> Float
getStrokeWidthFromStyle style = 
  case style of 
    Just { strokeWidth } -> sqrt strokeWidth
    Nothing -> 2.0

toPolygonElement : Style -> List Vector -> Svg msg
toPolygonElement style pts = 
  let 
    s = 
      let 
        str {x, y} = (String.fromFloat x) ++ "," ++ (String.fromFloat y)
      in
        pts |> List.map str |> String.join " "
    sw = getStrokeWidthFromStyle style.stroke  
  in
    Svg.polygon 
      [ stroke "Black"
      , strokeWidth <| String.fromFloat sw
      , fill "None"
      , points s ] []

toPolylineElement : Style -> List Vector -> Svg msg
toPolylineElement style pts = 
  let 
    s = 
      let 
        str {x, y} = (String.fromFloat x) ++ "," ++ (String.fromFloat y)
      in
        pts |> List.map str |> String.join " "
    sw = getStrokeWidthFromStyle style.stroke  
  in
    Svg.polyline 
      [ stroke "Black"
      , strokeWidth <| String.fromFloat sw
      , fill "None"
      , points s ] []

--#011f4b • #03396c • #005b96 • #6497b1 • #b3cde0

toStyleColorString : StyleColor -> String 
toStyleColorString color = 
  case color of 
    B -> "black" 
    G -> "grey"
    W -> "white"

getStrokePen : StrokeStyle -> (String, Float)
getStrokePen { strokeWidth, strokeColor } = 
  let 
    color = toStyleColorString strokeColor
  in 
    (color, strokeWidth)

getFillBrush : FillStyle -> String
getFillBrush { fillColor } = 
  toStyleColorString fillColor

toCurveElement : Style -> Vector -> Vector -> Vector -> Vector -> Svg msg
toCurveElement style pt1 pt2 pt3 pt4 = 
  let 
    toStr {x, y} = (toString x) ++ " " ++ (toString y)
    pt1s = toStr pt1
    pt2s = toStr pt2 
    pt3s = toStr pt3 
    pt4s = toStr pt4 
    dval = "M" ++ pt1s ++ " C " ++ pt2s ++ ", " ++ pt3s ++ ", " ++ pt4s
    strokew = getStrokeWidthFromStyle style.stroke  
    (strokeColor, sw) = 
      case style.stroke of 
        Just stroke -> getStrokePen stroke 
        Nothing -> ("none", strokew)
    fillColor = 
      case style.fill of 
        Just fill -> getFillBrush fill
        Nothing -> "none"
  in 
    Svg.path 
      [ stroke strokeColor
      , strokeWidth <| toString sw
      , strokeLinecap "butt"
      , fill fillColor
      , d dval ] []

toNextPointBezier : BezierShape -> String
toNextPointBezier { controlPoint1, controlPoint2, endPoint } = 
  let 
    toStr {x, y} = (toString x) ++ " " ++ (toString y)
    pt1s = toStr controlPoint1
    pt2s = toStr controlPoint2
    pt3s = toStr endPoint
  in 
    "C " ++ pt1s ++ ", " ++ pt2s ++ ", " ++ pt3s

toNextPointLineTo : LineTo -> String 
toNextPointLineTo { point } = 
  let 
    toStr {x, y} = (toString x) ++ " " ++ (toString y)
    pts = toStr point
  in 
    "L " ++ pts

toNextPoint : PathSegment -> String
toNextPoint segment = 
  case segment of 
    BezierSegment bz -> toNextPointBezier bz 
    LineSegment lt -> toNextPointLineTo lt

toLineElement : Style -> Vector -> Vector -> Svg msg 
toLineElement style lineStart lineEnd = 
  let
    strokew = getStrokeWidthFromStyle style.stroke  
    (strokeColor, sw) = 
      case style.stroke of 
        Just stroke -> getStrokePen stroke 
        Nothing -> ("black", strokew)
    fillColor = 
      case style.fill of 
        Just fill -> getFillBrush fill
        Nothing -> "none"
  in
    Svg.line 
      [ stroke strokeColor
      , strokeWidth <| toString sw
      , fill fillColor
      , x1 (toString lineStart.x)
      , y1 (toString lineStart.y)
      , x2 (toString lineEnd.x)
      , y2 (toString lineEnd.y) ] []

toCircleElement : Style -> Vector -> Float -> Svg msg
toCircleElement style center radius = 
  let
    strokew = getStrokeWidthFromStyle style.stroke  
    (strokeColor, sw) = 
      case style.stroke of 
        Just stroke -> getStrokePen stroke 
        Nothing -> ("black", strokew)
    fillColor = 
      case style.fill of 
        Just fill -> getFillBrush fill
        Nothing -> "none"
  in
    Svg.circle 
      [ stroke strokeColor
      , strokeWidth <| toString sw
      , fill fillColor
      , cx (toString center.x)
      , cy (toString center.y)
      , r (toString (radius * 10)) ] []

toPathElement : Style -> Vector -> Bool -> List PathSegment -> Svg msg
toPathElement style start closed beziers = 
  let 
    toStr {x, y} = (toString x) ++ " " ++ (toString y)    
    startStr = "M" ++ toStr start
    nextStrs = List.map toNextPoint beziers
    open = startStr :: nextStrs
    strs = if closed then open ++ [ "Z" ] else open 
    dval = strs |> String.join " "
    strokew = getStrokeWidthFromStyle style.stroke  
    (strokeColor, sw) = 
      case style.stroke of 
        Just stroke -> getStrokePen stroke 
        Nothing -> if closed then ("black", strokew) else ("white", strokew) 
    fillColor = 
      case style.fill of 
        Just fill -> if closed then getFillBrush fill else "none"
        Nothing -> "none"
  in 
    Svg.path 
      [ stroke strokeColor
      , strokeWidth <| toString sw
      , strokeLinecap "butt"
      , fill fillColor
      , d dval ] []

toSvgElement : Style -> Shape -> Svg msg
toSvgElement style shape = 
  case shape of  
    Polygon { points } -> toPolygonElement style points
    Polyline { pts } -> toPolylineElement style pts
    Curve { point1, point2, point3, point4 } ->
      toCurveElement style point1 point2 point3 point4 
    Path (startVector, closed, segments) -> 
      toPathElement style startVector closed segments
    Circle { center, radius } -> 
      toCircleElement style center radius 
    Line { lineStart, lineEnd } -> 
      toLineElement style lineStart lineEnd 

toBoxPolylineElement : List Vector -> Svg msg
toBoxPolylineElement pts = 
  let 
    s = 
      let 
        str {x, y} = (toString x) ++ "," ++ (toString y)
      in
        pts |> List.map str |> String.join " "
    sw = 1
  in
    Svg.polyline 
      [ stroke "Grey"
      , strokeWidth <| toString sw
      , strokeDasharray "2,2"
      , fill "None"
      , points s ] []

toBoxLine : (Vector -> Vector) -> Vector -> Vector -> (String, String) -> Svg msg
toBoxLine m v1 v2 (name, color) = 
  let 
    w1 = m v1 
    w2 = m (add v1 v2) 
  in
    Svg.line 
      [ x1 <| toString w1.x
      , y1 <| toString w1.y 
      , x2 <| toString w2.x
      , y2 <| toString w2.y
      , stroke color
      , strokeWidth "1.5"
      , markerEnd <| "url(#" ++ name ++ ")" ] []

acolor : String 
acolor = "#b22327"

bcolor : String 
bcolor = "#2381bf"

ccolor : String 
ccolor = "#27b15b"

toBoxArrows : (Vector -> Vector) -> Box -> List (Svg msg)
toBoxArrows m { a, b, c } =
  [ toBoxLine m { x = 0, y = 0 } a ("a-arrow", acolor)
  , toBoxLine m a b ("b-arrow", bcolor)
  , toBoxLine m a c ("c-arrow", ccolor) ]

toBoxShape : (Vector -> Vector) -> Box -> List Vector
toBoxShape m { a, b, c } = 
  let
    b2 = add a b
    c2 = add a c 
    d = add a (add b c)
    pts = [m a, m b2, m d, m c2, m a]
  in
    pts

toBoxArrowLines : (Vector -> Vector) -> Box -> List Vector
toBoxArrowLines m { a, b, c } = 
  let
    b2 = add a b
    c2 = add a c 
    d = add a (add b c)
    pts = [m a, m b2, m d, m c2, m a]
  in
    pts

createAxisList : Int -> Int -> List Int 
createAxisList interval n = 
  if n < 0 then []
  else 
    let next = n - interval
    in 
      n :: createAxisList interval next

createXAxisElement : Int -> Int -> Svg msg
createXAxisElement y x = 
  Svg.line 
    [ x1 <| String.fromInt x
    , y1 <| String.fromInt y
    , x2 <| String.fromInt x
    , y2 <| String.fromInt (y - 3)
    , stroke "black"
    , strokeWidth "1.0" ] []

createXAxis : Int -> Int -> List (Svg msg) 
createXAxis xmax ypos = 
  let 
    axisList = createAxisList 20 xmax
  in 
    axisList |> List.map (\x -> xmax - x) |> List.map (createXAxisElement ypos)

createYAxisElement : Int -> Int -> Svg msg
createYAxisElement x y = 
  Svg.line 
    [ x1 <| String.fromInt x
    , y1 <| String.fromInt y
    , x2 <| String.fromInt (x + 3)
    , y2 <| String.fromInt y
    , stroke "black"
    , strokeWidth "1.0" ] []

createYAxis : Int -> Int -> List (Svg msg) 
createYAxis xpos ymax = 
  let 
    axisList = createAxisList 20 ymax
  in 
    axisList |> List.map (createYAxisElement xpos)

createMarker : (String, String) -> Svg msg
createMarker (markerId, color) = 
  Svg.marker 
    [ id markerId
    , markerWidth "10"
    , markerHeight "10"
    , refX "9"
    , refY "3"
    , orient "auto"
    , markerUnits "strokeWidth" ] 
    [ Svg.path 
      [ d "M0,0 L0,6 L9,3 z"
      , fill color ] [] ]

createAxes : Int -> Int -> List (Svg msg)
createAxes w h = 
  let 
    xx = String.fromInt 0
    yy = String.fromInt h
    axisColor = "black"
    xAxis =     
      Svg.line 
        [ x1 <| String.fromInt 0
        , y1 yy
        , x2 <| String.fromInt w
        , y2 yy
        , stroke axisColor
        , strokeWidth "1.5" ] []
    yAxis =  
      Svg.line 
        [ x1 xx
        , y1 <| String.fromInt 0
        , x2 xx
        , y2 <| String.fromInt w
        , stroke axisColor
        , strokeWidth "1.5" ] []
  in 
    [ xAxis, yAxis ] ++ createXAxis w h ++ createYAxis 0 h

toSvgWithBoxes : ViewBox -> (Int, Int) -> List Box -> Rendering -> Svg msg 
toSvgWithBoxes vb bounds boxes rendering = 
  let
    (w, h) = bounds
    viewBoxValue = ["0", "0", String.fromInt w, String.fromInt h] |> String.join " "
    mirror = mirrorVector <| toFloat h
    boxShapes = boxes |> List.map (toBoxShape mirror) |> List.map toBoxPolylineElement
    boxArrows = boxes |> List.concatMap (toBoxArrows mirror)
    toElement (shape, style) = toSvgElement style (mirrorShape mirror shape)
    things = rendering |> List.map toElement
    axes = createAxes w h
    markers =
      [ ("a-arrow", acolor)
      , ("b-arrow", bcolor)
      , ("c-arrow", ccolor) ]
    defs = markers |> List.map createMarker |> Svg.defs []
    svgElements = 
      case boxes of 
      [] -> things
      _ -> ([defs] ++ things ++ boxShapes ++ boxArrows ++ axes)
    viewBoxStr = [ i2s vb.x, i2s vb.y, i2s vb.width, i2s vb.height ] |> String.join " "
  in
    svg
      [ version "1.1"
      , Html.Attributes.attribute "xmlns" "http://www.w3.org/2000/svg"
      , viewBox viewBoxStr
      , x "0"
      , y "0"
      , width (String.fromInt w)
      , height (String.fromInt h) ]
      -- , Svg.Attributes.style "background-color:yellow" ]
      svgElements

toSvg : ViewBox -> (Int, Int) -> Rendering -> Svg msg 
toSvg vb bounds rendering = 
  toSvgWithBoxes vb bounds [] rendering 
