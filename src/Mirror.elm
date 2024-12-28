module Mirror exposing (..) 

import Vector exposing (Vector)
import Shape exposing (..)

mirrorVector : Float -> Vector -> Vector 
mirrorVector height { x, y } = 
  { x = x, y = height - y }

mirrorBezier : (Vector -> Vector) -> BezierShape -> BezierShape 
mirrorBezier mirror { controlPoint1, controlPoint2, endPoint } = 
  { controlPoint1 = mirror controlPoint1 
  , controlPoint2 = mirror controlPoint2 
  , endPoint = mirror endPoint }

mirrorLineTo : (Vector -> Vector) -> LineTo -> LineTo 
mirrorLineTo mirror { point } = 
  { point = mirror point }

mirrorPathSegment : (Vector -> Vector) -> PathSegment -> PathSegment 
mirrorPathSegment mirror segment = 
  case segment of 
    BezierSegment bz -> BezierSegment (mirrorBezier mirror bz)
    LineSegment lt -> LineSegment (mirrorLineTo mirror lt)

mirrorShape : (Vector -> Vector) -> Shape -> Shape
mirrorShape mirror shape = 
  case shape of  
    Line { lineStart, lineEnd } -> 
      Line { lineStart = mirror lineStart, lineEnd = mirror lineEnd }
    Polygon { points } -> 
      Polygon { points = points |> List.map mirror }
    Polyline { pts } -> 
      Polyline { pts = pts |> List.map mirror }
    Curve { point1, point2, point3, point4  } ->
      Curve { point1 = mirror point1
            , point2 = mirror point2 
            , point3 = mirror point3 
            , point4 = mirror point4 }
    Path (start, segments) -> 
      Path (mirror start, List.map (mirrorPathSegment mirror) segments)
