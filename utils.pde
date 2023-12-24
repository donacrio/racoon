ArrayList<LineString> getLineStrings(Geometry geom) {
  ArrayList<LineString> lines = new ArrayList<LineString>();
  if(geom.getGeometryType() == Geometry.TYPENAME_POLYGON) {
    Polygon polygon = (Polygon) geom;
    lines.add(polygon.getExteriorRing());
    for(int k=0; k<polygon.getNumInteriorRing(); k++) {
      lines.add(polygon.getInteriorRingN(k));
    }
  } else if(geom.getGeometryType() == Geometry.TYPENAME_LINESTRING) {
    lines.add((LineString) geom);
  }
  return lines;
}

Geometry gridify(Geometry geom, int incr) {
  ArrayList<LineString> lines = getLineStrings(geom);
  ArrayList<LineString> gridifiedLines = new ArrayList<LineString>();
  for(LineString line : lines) {
    ArrayList<Coordinate> coords = new ArrayList<Coordinate>();
    Integer prevX = 0;
    Integer prevY = 0;
    for(Coordinate coord : line.getCoordinates()) {        //<>//
     int x = round((float) coord.x / incr) * incr;
     int y = round((float) coord.y / incr) * incr;
     if(x!=prevX || y!=prevY) {
       coords.add(new Coordinate(x, y));
     }
     prevX = x;
     prevY = y;
    }
    if(coords.size() > 1) {
        gridifiedLines.add(GF.createLineString(coords.toArray(new Coordinate[0])));
    }
  }
  return GF.createMultiLineString(gridifiedLines.toArray(new LineString[0]));
}

Geometry simplify(Geometry geom, float tolerance) {
  return DouglasPeuckerSimplifier.simplify(geom, tolerance);
}
