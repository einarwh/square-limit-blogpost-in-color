module Shape exposing (..)

import Vector exposing (..)

type alias LineShape = 
  { lineStart : Vector
  , lineEnd : Vector}

type alias PolygonShape = 
  { points : List Vector }

type alias PolylineShape = 
  { pts : List Vector }

type alias CurveShape = 
  { point1 : Vector
  , point2 : Vector
  , point3 : Vector
  , point4 : Vector }

type alias BezierShape = 
  { controlPoint1 : Vector
  , controlPoint2 : Vector
  , endPoint : Vector }

type alias LineTo = 
  { point : Vector }

type alias CircleShape = 
  { center : Vector 
  , radius : Float }

type PathSegment =
  BezierSegment BezierShape 
  | LineSegment LineTo

type Shape = 
    Line LineShape 
  | Polygon PolygonShape
  | Polyline PolylineShape
  | Curve CurveShape
  | Path (Vector, Bool, List PathSegment)
  | Circle CircleShape

type alias Name = String 

type alias NamedShape = (Name, Shape)
  