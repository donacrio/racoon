ArrayList<LineString> getLineStrings(Polygon polygon) {
  ArrayList<LineString> lines = new ArrayList<LineString>();
    lines.add(polygon.getExteriorRing());
    for(int k=0; k<polygon.getNumInteriorRing(); k++) {
      lines.add(polygon.getInteriorRingN(k));
  }
  return lines;
}

LineString gridify(LineString line, int incr) {
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
  if(coords.size() <= 1) {
      return GF.createLineString();
  }
  return GF.createLineString(coords.toArray(new Coordinate[0]));
}
