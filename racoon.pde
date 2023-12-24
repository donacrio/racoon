import java.util.stream.Collectors;
import processing.svg.*;

int N_RACOONS_ROW = 5;
int N_RACOONS_COL = 5;

int GRID_INCR = 1;

GeometryFactory GF;

void setup() {
  size(720, 720);
  
  GF = new GeometryFactory();
  
  // Load Racoon geometry
  Geometry baseRacoon = GF.createPolygon();
  String[] lines = loadStrings("data/racoon.txt");
  WKTReader reader = new WKTReader(GF);
  try {
    baseRacoon = reader.read(lines[0]);
  } catch(ParseException e) {
    println(e);
  }
  
  // Transforms base racoon to base shape
  AffineTransformation baseTransformation = new AffineTransformation();
  Point centroid = baseRacoon.getCentroid();
  baseTransformation.translate(-centroid.getX(),-centroid.getY());
  double diameter = 2*(new MinimumBoundingCircle(baseRacoon)).getRadius();
  baseTransformation.scale(0.95*width/(diameter*N_RACOONS_ROW),0.95*height/(diameter*N_RACOONS_COL));
  baseTransformation.rotate(PI);
  baseRacoon = baseTransformation.transform(baseRacoon);
  
  
  // Progressively add new racoons
  ArrayList<Geometry> racoons = new ArrayList<Geometry>();
  ArrayList<LineString> baseRacoonLines = new ArrayList<LineString>();
  for(int j=0; j<baseRacoon.getNumGeometries(); j++) {
    Polygon inner = (Polygon) baseRacoon.getGeometryN(j);
    baseRacoonLines.addAll(getLineStrings(inner));
  }
  for(int i=0; i<N_RACOONS_ROW; i++) {
    // Gridify racoon
    ArrayList<LineString> gridifiedRacoonLines = new ArrayList<LineString>();
    for(LineString line : baseRacoonLines) {
      gridifiedRacoonLines.add(gridify(line, GRID_INCR * (2*i+1)));
    }
    Geometry gridifiedRacoon = GF.createMultiLineString(gridifiedRacoonLines.toArray(new LineString[0]));

    // Simplify racoon
    for(int j=0; j<N_RACOONS_COL; j++) {
      // Simplify with geometry simplifier
      float jTolerance = 10 * log(map(j, 0, N_RACOONS_COL-1, 1, 2.72));
      println(jTolerance);
      Geometry racoon = DouglasPeuckerSimplifier.simplify(gridifiedRacoon, jTolerance);
      
      AffineTransformation t = new AffineTransformation();
      t.translate((width/N_RACOONS_ROW) * (i+0.5), (height/N_RACOONS_COL) * (j+0.5));
      racoon = t.transform(racoon);
      racoons.add(racoon);
    }
  }
  
  
  beginRecord(SVG, "out/final.svg");
  
  background(255);
  noFill();
  stroke(0);    
  for(Geometry racoon : racoons) {
    for(int i=0; i<racoon.getNumGeometries(); i++) {
      LineString racoonPoly = (LineString) racoon.getGeometryN(i);
      //for(LineString line : getLineStrings(racoonPoly)) {
        beginShape();
        for(Coordinate coord : racoonPoly.getCoordinates()) {
          vertex((float) coord.x, (float) coord.y);
        }
        endShape();
      //}
    }
  }
  
  endRecord();
  println("Done");
  noLoop();
}
