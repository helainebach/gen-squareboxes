/**
 * Recursive Box Design
 *
 * This sketch generates designs for a pen plotter using recursive boxes.
 * 
 * Key Controls:
 * - 'e' or 'E': Export the current design as an SVG file.
 * - 't' or 'T': Toggle display of parameters.
 * - 'c' or 'C': Toggle inverted color.
 * - 'g' or 'G': Generate a new design with a new color palette.
 * - '+' or '-': Increase leaf probability.
 * - 'LEFT' or 'RIGHT': Increase palette/layer count.
 * - 'UP' or 'DOWN': Increase/decrease recursion depth.
 * - 'D' or 'd': Decrease grid size.
 * - 'I' or 'i': Increase grid size.
 */

import processing.svg.*;

int layerCount = 3;
String uniqueID;
boolean displayParams = false;
boolean invertedColors = false;
int gridSize = 3;
int recursionDepth = 6;
float leafProbability = 0.5;

SquareBox rootBox;
color[] palette;

void setup() {
  size(800, 800);
  noLoop();
  generatePalette();
  generateDesign();
}

void draw() {
  background(!invertedColors ? 255 : 0);
  if (rootBox != null) {
    rootBox.draw();
  }
  if (displayParams) {
    displayParameters();
  }
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    invertedColors = !invertedColors;
    redraw();
  } else if (key == 'e' || key == 'E') {
    exportDesign();
  } else if (key == 'g' || key == 'G') {
    generatePalette();
    generateDesign();
    redraw();
  } else if (key == 't' || key == 'T') {
    displayParams = !displayParams;
    redraw();
  } else if (key == '+') {
    leafProbability = constrain(leafProbability + 0.1, 0, 1);
    generateDesign();
    redraw();
  } else if (key == '-') {
    leafProbability = constrain(leafProbability - 0.1, 0, 1);
    generateDesign();
    redraw();
  } else if (keyCode == LEFT) {
    layerCount = constrain(layerCount - 1, 1, 6);
    generatePalette();
    generateDesign();
    redraw();
  } else if (keyCode == RIGHT) {
    layerCount = constrain(layerCount + 1, 1, 6);
    generatePalette();
    generateDesign();
    redraw();
  } else if (keyCode == UP) {
    recursionDepth = constrain(recursionDepth + 1, 1, 6);
    generateDesign();
    redraw();
  } else if (keyCode == DOWN) {
    recursionDepth = constrain(recursionDepth - 1, 1, 6);
    generateDesign();
    redraw();
  } else if (key == 'd' || key == 'D') {
    gridSize = constrain(gridSize - 1, 1, 3);
    generateDesign();
    redraw();
  } else if (key == 'i' || key == 'I') {
    gridSize = constrain(gridSize + 1, 1, 3);
    generateDesign();
    redraw();
  }
}

class SquareBox{
  PVector position;
  float size;
  color boxColor;
  SquareBox[][] boxes;
  boolean isLeaf;
  int depth;
    
  SquareBox(PVector position, float size, color boxColor, boolean isLeaf, int depth){
    this.position = position;
    this.size = size;
    this.boxColor = boxColor;
    this.isLeaf = isLeaf || depth >= recursionDepth;
    this.depth = depth;
    if (!this.isLeaf) {
      boxes = new SquareBox[gridSize][gridSize];
      float newSize = size / gridSize;
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          PVector newPos = new PVector(snapToGrid(position.x + i * newSize), snapToGrid(position.y + j * newSize));
          boxes[i][j] = new SquareBox(newPos, newSize, palette[depth % palette.length], random(1) > leafProbability, depth + 1);
        }
      }
    }
  }
  
  void draw(){
    if (isLeaf) {
      float inset = size * 0.1;
      color drawColor = invertedColors ? color(255 - red(boxColor), 255 - green(boxColor), 255 - blue(boxColor)) : boxColor;
      fill(invertedColors ? 0 : 255); // Background color
      stroke(drawColor);
      strokeWeight(width < 100 ? 2 : 1); // Lower stroke weight for smaller boxes
      beginShape();
      curveVertex(position.x + inset, position.y + 2 * inset); //Corner 1
      curveVertex(position.x + 2 * inset, position.y + inset); //Corner 1 to 2
      curveVertex(position.x + size - 2 * inset, position.y + inset); //Corner 2
      curveVertex(position.x + size - inset, position.y + 2 * inset); //Corner 2 to 3
      curveVertex(position.x + size - inset, position.y + size - 2 * inset); //Corner 3
      curveVertex(position.x + size - 2 * inset, position.y + size - inset); //Corner 3 to 4
      curveVertex(position.x + 2 * inset, position.y + size - inset); //Corner 4
      curveVertex(position.x + inset, position.y + size - 2 * inset); //Corner 4 to 1
      curveVertex(position.x + inset, position.y + 2 * inset); //Corner 1
      curveVertex(position.x + 2 * inset, position.y + inset); //Corner 1 to 2
      curveVertex(position.x + size - 2 * inset, position.y + inset); //Corner 2
      endShape(CLOSE);
    } else {
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          boxes[i][j].draw();
        }
      }
    }
  }
}

void generatePalette() {
  palette = new color[layerCount];
  for (int i = 0; i < layerCount; i++) {
    palette[i] = color(random(50, 150), random(50, 150), random(50, 150)); // Colors easily visible on white background
  }
}

void generateDesign() {
  uniqueID = nf((int)random(10000), 4); // Generate a unique ID
  rootBox = new SquareBox(new PVector(0, 0), width, palette[0], false, 0);
  redraw();
}

void exportDesign() {
  String fileName = "recurse_" + uniqueID + ".svg";
  beginRecord(SVG, fileName);
  rootBox.draw();
  endRecord();
  println("Design exported as: " + sketchPath(fileName));
}

int snapToGrid(float value) {
  return (int)(round(value / gridSize) * gridSize);
}

void displayParameters() {
  fill(0);
  noStroke();
  rect(0, height - 60, width, 50); // Black background for text
  fill(255);
  textSize(13);
  StringBuilder sb = new StringBuilder();
  sb.append("Layers(Left/Right): ").append(layerCount)
    .append(" | Grid Size(d/i): ").append(gridSize)
    .append(" | Recursion Depth(Up/Down): ").append(recursionDepth)
    .append(" | Leaf Probability(+/-): ").append(leafProbability)
    .append(" | Colors(c): ").append(invertedColors ? "Inverted" : "Normal")
    .append("\n")
    .append("Toggle Overlay (t) | Export (e)");
  text(sb.toString(), 10, height - 40);
}