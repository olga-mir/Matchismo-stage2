//
//  SetCardView.m
//  Matchismo_stage2
//
//  Created by Olga on 29/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "SetCardView.h"
#import "SetCard.h"
#import "Utils.h"

@interface SetCardView()

@property (nonatomic) NSUInteger rank;            // 1, 2 or 3
@property (strong, nonatomic) UIColor *color;     // greenColor, redColor, purpleColor
@property (strong, nonatomic) NSString *filling;  // solid, striped or unfilled
@property (strong, nonatomic) NSString *shape;    // squiggles, diamonds or ovals

@end

@implementation SetCardView


- (void)setSelected:(BOOL)selected {
  _selected = selected;
  [self setNeedsDisplay];
}

// It is NOT a getter to the 'selected' property. 
- (BOOL)getSelectedState
{
  return self.selected;
}

- (NSString *) description
{
  return self.contents;
}

/**
 *  Designated initializer. Takes the Set card provided and a frame and creates the view that represents this Set card. The card must be of type Set card, otherwise assertion is fired.
 *
 *  @param frame   view's frame
 *  @param setCard Set card to represent
 *
 *  @return the view representing given Set card
 */
- (instancetype)initWithFrame:(CGRect)frame withCard:(SetCard *)setCard
{
  SYSASSERT([setCard isKindOfClass:[SetCard class]], @"Type mismatch: Set card view cannot be created without valid card of Set type");
  
  self = [super initWithFrame:frame];
  
  if (self) {
    self.contents = setCard.contents;
    
    SYSASSERT([setCard isKindOfClass:[SetCard class]], @"Type mismatch: Set card view cannot be created without valid card of SetCard type");
    
    _rank     = setCard.rank;
    _filling  = setCard.filling;
    _shape    = setCard.shape;
    
    if ([setCard.color isEqualToString:@"red"])
      _color = [UIColor redColor];
    else if ([setCard.color isEqualToString:@"green"])
      _color = [UIColor greenColor];
    else if ([setCard.color isEqualToString:@"purple"])
      _color = [UIColor purpleColor];
    else
      SYSASSERT(NO, @"Invalid Color");
  }
  return self;
}

- (void)awakeFromNib
{
  [self setup];
}

#pragma mark - Behavior

- (void)toggleSelectedState
{
  // When dealt the Set cards are always face up, so when card is selected
  // it must be highlighted to make the selected look
  self.selected = !self.selected;

  // it's a bit of cheating, since the actual selection/deselection will occur in the next drawing cycle. But for the purposes of this app it is good enough
  NSString *notificationName = (self.selected) ? CARD_SELECTION_COMPLETED_NOTIFICATION : CARD_DESELECTION_COMPLETED_NOTIFICATION;
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

#pragma mark - Drawing

#define CORNER_RADIUS 12.0
#define CARD_ASPECT_RATIO 0.75

- (CGFloat)getCardAspectRatio
{
  NSLog(@"SET CARD getCardAspectRatio");
  return CARD_ASPECT_RATIO;
}

#define VERTICAL_OFFSET1_PERCENTAGE 0.1
#define VERTICAL_OFFSET2_PERCENTAGE 0.25

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / 180.0; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }


- (void)drawRect:(CGRect)rect
{
  UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
  [roundedRect addClip];
  [[UIColor whiteColor] setFill];
  [roundedRect fill];
  
  if (self.selected) {
    [[UIColor greenColor] setStroke];
    roundedRect.lineWidth = 6.0;
    [roundedRect stroke];
  } else {
    [[UIColor blackColor] setStroke];
    roundedRect.lineWidth = 1.0;
    [roundedRect stroke];
  }
  
  // for rank 1 or 3 - draw a shape in the middle of the card
  if ((self.rank == 1) || (self.rank == 3)) {
    [self drawShapeWithVerticalOffset:0];
  }
  
  // for 2 - draw two shapes on equal distance from the vertical center
  if (self.rank == 2) {
    [self drawShapeWithVerticalOffset:VERTICAL_OFFSET1_PERCENTAGE];
  }
  
  // for 3 - add two more shapes on equal distances from the vertical center,
  // in addition to the one that is already in the center
  if (self.rank == 3) {
    [self drawShapeWithVerticalOffset:VERTICAL_OFFSET2_PERCENTAGE];
  }
}

#define SET_CARD_SHAPE_ASPECT_RATIO 3
- (CGFloat)shapeWidth { return self.bounds.size.width * 0.65; }
- (CGFloat)shapeHeight { return [self shapeWidth] / SET_CARD_SHAPE_ASPECT_RATIO; }


/**
 *  Draw one or two shapes on equal distance from vertical center of the view
    if offset == 0 there will be only one shape which be positioned exactly in the middle of self.frame
    if offset != 0 there wiil be two shapes positioned above and below the center of the frame at distance specified by offset
 
 *
 *  @param offset offset (in percentage) from the vertical center of the view
 */
- (void)drawShapeWithVerticalOffset:(CGFloat)offset
{
  [self.color setFill];
  
  CGPoint middle = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
  
  CGFloat shapeWidth = [self shapeWidth];
  CGFloat shapeHeight = [self shapeHeight];
  
  CGPoint origin;
  CGRect rect = CGRectMake(0, 0, shapeWidth, shapeHeight); // origin will be calculated later, separately for eash shape

  NSMutableArray *pathsArray = [[NSMutableArray alloc] init]; // array of shape UIBezierPath's
  
  if (offset == 0) {
    origin = CGPointMake(middle.x - shapeWidth / 2.0, middle.y - shapeHeight / 2.0);
    rect.origin = origin;

    [pathsArray addObject:[self createPathInRect:rect]];
  
  } else { // offset is not 0 ==> draw two shapes on equal distance from 'equator'
    
    CGFloat y = middle.y - shapeHeight / 2.0 - offset * self.bounds.size.height;
    origin = CGPointMake(middle.x - shapeWidth / 2.0, y);
  
    rect.origin = origin;
    [pathsArray addObject:[self createPathInRect:rect]];
    
    // now the second shape
    
    origin.y += offset * 2.0 * self.bounds.size.height;
    rect.origin = origin;

    [pathsArray addObject:[self createPathInRect:rect]];
  }
  //[pathsArray makeObjectsPerformSelector:@selector(fill)];
  for (UIBezierPath *path in pathsArray) {
    [self fillPath:path];
  }
}

/**
 *  Fill the inside of the Set card game shape
 *
 *  @param path is the Bezier path representing the shape
 */
- (void)fillPath:(UIBezierPath *)path
{
  if ([self.filling isEqual:@"solid"]) {
    [path fill];
  } else if ([self.filling isEqual:@"stripped"]) {
    // it should be stripped, not shaded, but I do it for simplisity - I have more interesting stuff to learn
    [path fillWithBlendMode:kCGBlendModeNormal alpha:0.2];
    [self.color setStroke];
    path.lineWidth = 1.0;
    [path stroke];
  } else if ([self.filling isEqual:@"unfilled"]) {
    [self.color setStroke];
    path.lineWidth = 1.0;
    [path stroke];
  } else {
    SYSASSERT(NO, ([NSString stringWithFormat:@"Invalid filling type, %@", self.filling]));
  }
  
}

- (UIBezierPath *)createPathInRect:(CGRect)rect
{
  UIBezierPath *path;
  
  if ([self.shape isEqual:@"oval"]) {
    path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:rect.size.height/2.0];
  } else if ([self.shape isEqual:@"diamond"]) {
    path = [self drawDiamondInRect:rect];
  } else if ([self.shape isEqual:@"squiggle"]) {
    path = [self drawSquiggleInRect:rect];
  } else {
    SYSASSERT(NO, @"Can't draw: Unknown shape");
  }
  
  return path;
}

- (UIBezierPath *)drawDiamondInRect:(CGRect)rect
{
  UIBezierPath *diamondPath = [[UIBezierPath alloc] init];
  
  CGFloat halfWidth  = rect.size.width  / 2.0;
  CGFloat halfHeight = rect.size.height / 2.0;
  
  CGPoint topPoint    = CGPointMake(rect.origin.x + halfWidth, rect.origin.y);
  CGPoint leftPoint   = CGPointMake(rect.origin.x, rect.origin.y + halfHeight);
  CGPoint bottomPoint = CGPointMake(rect.origin.x + halfWidth, rect.origin.y + rect.size.height);
  CGPoint rightPoint  = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + halfHeight);
  
  [diamondPath moveToPoint:topPoint];
  [diamondPath addLineToPoint:leftPoint];
  [diamondPath addLineToPoint:bottomPoint];
  [diamondPath addLineToPoint:rightPoint];
  [diamondPath closePath];
  
  return diamondPath;
}

- (UIBezierPath *)drawSquiggleInRect:(CGRect)rect
{
  UIBezierPath *squigglePath = [[UIBezierPath alloc] init];
  
  CGPoint bottomPoint = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
  CGPoint rightPoint = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
  
  [squigglePath moveToPoint:rect.origin];
  [squigglePath addLineToPoint:bottomPoint];
  [squigglePath addLineToPoint:rightPoint];
  [squigglePath closePath];
  
  return squigglePath;

  
  /* // This code builds a shape resembling a squiggle
     // in fillings other than 'filled' there is a path visible going between the two points
     // Conquering the Bezier path is not in the priorities at this stage, so I replace 
     // it with simple shape to free myself to more interesting stuff.
   
  CGFloat y = rect.origin.y + rect.size.height / 2.0;
  CGPoint startPoint = CGPointMake(rect.origin.x, y);
  CGPoint endPoint   = CGPointMake(rect.origin.x + rect.size.width, y);
  [squigglePath moveToPoint:startPoint];
  [squigglePath addLineToPoint:endPoint];
  CGFloat pathCenter_x = rect.origin.x + rect.size.width / 2.0;
  CGPoint controlPoint1 = CGPointMake(pathCenter_x, y - 1.4 * rect.size.height);
  CGPoint controlPoint2 = CGPointMake(pathCenter_x, y + rect.size.height / 1.5);
  [squigglePath addCurveToPoint:startPoint controlPoint1:controlPoint2 controlPoint2:controlPoint1];
  
  [squigglePath addLineToPoint:startPoint];
  
  // flip the controlPoint1 y coordinate over the 'y' which is the coordinate of the straight line that we want to curve
  // new_cp2.y = y + (y - old_cp2.y)
  controlPoint1 = CGPointMake(pathCenter_x, 2.0 * y - controlPoint1.y);
  controlPoint2 = CGPointMake(pathCenter_x, 2.0 * y - controlPoint2.y);
  [squigglePath addCurveToPoint:endPoint controlPoint1:controlPoint2 controlPoint2:controlPoint1];
  [squigglePath closePath];
  
  return squigglePath;
   */
}


@end
