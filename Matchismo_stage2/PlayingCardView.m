//
//  PlayingCardView.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "PlayingCardView.h"
#import "PlayingCard.h"
#import "Utils.h"

@interface PlayingCardView()


@property (strong, nonatomic) NSString *suit;
@property (nonatomic) NSUInteger rank;

+ (NSUInteger)maxRank;
+ (NSArray *)validSuits;

@end

@implementation PlayingCardView

#pragma mark - Initialization
// designated initializer
// it is provided that the card is the Playing Card and is not checked here.
- (instancetype)initWithFrame:(CGRect)frame withCard:(PlayingCard *)playingCard
{
  self = [super initWithFrame:frame];
  
  if (self) {
    SYSASSERT([playingCard isKindOfClass:[PlayingCard class]], @"Type mismatch: Playing card view cannot be created without valid card of PlayingCard type");

    self.rank = playingCard.rank;
    self.suit = playingCard.suit;
  }
  return self;
}

- (void)awakeFromNib
{
  [self setup];
}


#pragma mark - Properties

+ (NSArray *)validSuits
{
  return @[@"♠", @"♣", @"♥", @"♦"];
}

+ (NSArray *)rankStrings
{
  return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"];
}

+ (NSUInteger) maxRank {return [[self rankStrings] count] - 1;}


@synthesize faceCardScaleFactor = _faceCardScaleFactor;

#define DEFAULT_FACE_CARD_SCALE_FACTOR 0.90

- (CGFloat)faceScaleFactor
{
  if (!_faceCardScaleFactor) _faceCardScaleFactor = DEFAULT_FACE_CARD_SCALE_FACTOR;
  return _faceCardScaleFactor;
}

- (void) setFaceCardScaleFactor:(CGFloat)faceCardScaleFactor
{
  SYSASSERT(((faceCardScaleFactor) > 0 && (faceCardScaleFactor <= 1)), ([NSString stringWithFormat:@"Invalid faceCardScaleFactor, must be in range (0, 1], but provided %f", faceCardScaleFactor]));
  
  _faceCardScaleFactor = faceCardScaleFactor;
  [self setNeedsDisplay];
}

- (void) setRank:(NSUInteger) rank
{
  SYSASSERT(((rank > 0) && (rank <= [PlayingCardView maxRank])), ([NSString stringWithFormat:@"Invalid rank: %d", rank]));
  
  _rank = rank;
  [self setNeedsDisplay];
}

- (void) setSuit:(NSString *)suit
{
  SYSASSERT(([[PlayingCardView validSuits] containsObject:suit]), ([NSString stringWithFormat:@"Invalid suit: %@", suit]));
  
  _suit = suit;
  [self setNeedsDisplay];
}

- (BOOL)getSelectedState
{
  return self.faceUp;
}

- (NSString *)contents
{
  return [[self rankAsString] stringByAppendingString:self.suit];
}

#pragma mark - Card Behavior

- (void)toggleSelectedState
{
  [UIView transitionWithView:self
                    duration:0.3
                     options:((self.faceUp) ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight)
                  animations:^{
                    self.faceUp = !self.faceUp;
                  }
                  completion:^(BOOL isFinished){
                    if (isFinished) {
                      NSString *notificationName = (self.faceUp) ? CARD_SELECTION_COMPLETED_NOTIFICATION : CARD_DESELECTION_COMPLETED_NOTIFICATION;
                      NSLog(@"Posting notification: %@", notificationName);
                      [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
                      NSLog(@"Posted notification: %@", notificationName);
                    }
                  }
   ];
}


#pragma mark - Drawing

/**
 *  Get the string representation of the card's rank value
 *
 *  @return the string representing the card's rank
 */
- (NSString *)rankAsString
{
  // self.rank is always a valid number. The data integrety verified at the setter.
  return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"][self.rank];
}


// default aspect ratio of the playing card ("Poker" type) - 56/88
#define CARD_ASPECT_RATIO 0.625

- (CGFloat)getCardAspectRatio
{
  NSLog(@"PLAYING CARD getCardAspectRatio");
  return CARD_ASPECT_RATIO;
}


#define CORNER_FONT_STANDART_HEIGHT 180.0
#define CORNER_RADIUS 12.0

- (CGFloat)cornerScaleFactor { return self.bounds.size.height / CORNER_FONT_STANDART_HEIGHT; }
- (CGFloat)cornerOffset { return [self cornerRadius] / 3.0; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }



- (void)drawRect:(CGRect)rect
{
  UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
  [roundedRect addClip];
  [[UIColor whiteColor] setFill];
  [roundedRect fill];
  [[UIColor blackColor] setStroke];
  [roundedRect stroke];
  
  if (self.faceUp) {
    UIImage *faceImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@.jpg", [self rankAsString], self.suit]];
    if (faceImage) {
      CGRect imageRect = CGRectInset(self.bounds,
                                     self.bounds.size.width * (1.0 - self.faceCardScaleFactor),
                                     self.bounds.size.height * (1.0 - self.faceCardScaleFactor));
      [faceImage drawInRect:imageRect];
    } else {
      [self drawPips];
    }
    [self drawCorners];
  } else {
    [[UIImage imageNamed:@"cardback.png"] drawInRect:self.bounds];
  }
}

// Draw the letter for the suit and the symbol for the rank in the upper left corner
// and upside down on the lower right corner
- (void) drawCorners
{
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = NSTextAlignmentCenter;
  
  UIFont *cornerFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  cornerFont = [cornerFont fontWithSize:cornerFont.pointSize * [self cornerScaleFactor]];
  
  NSAttributedString *cornerText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", [self rankAsString], self.suit] attributes:@{NSFontAttributeName : cornerFont, NSParagraphStyleAttributeName : paragraphStyle}];
  
  CGRect textBounds;
  textBounds.origin = CGPointMake([self cornerOffset], [self cornerOffset]);
  textBounds.size = [cornerText size];
  [cornerText drawInRect:textBounds];

  
  // now draw in the lower corner
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);
  CGContextRotateCTM(context, M_PI);

  [cornerText drawInRect:textBounds];
}

#pragma mark - Pips

#define PIP_HOFFSET_PERCENTAGE 0.165
#define PIP_VOFFSET1_PERCENTAGE 0.090
#define PIP_VOFFSET2_PERCENTAGE 0.175
#define PIP_VOFFSET3_PERCENTAGE 0.270

- (void) drawPips
{
  if ((self.rank == 1) || (self.rank == 5) || (self.rank == 9) || (self.rank == 3)) {
    [self drawPipsWithHorizontalOffset:0
                        verticalOffset:0
                    mirroredVertically:NO];
  }
  
  if ((self.rank == 6) || (self.rank == 7) || (self.rank == 8)) {
    [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                        verticalOffset:0
                    mirroredVertically:NO];
  }
  
  if ((self.rank == 2) || (self.rank == 3) || (self.rank == 7) || (self.rank == 8) || (self.rank == 10)) {
    [self drawPipsWithHorizontalOffset:0
                        verticalOffset:PIP_VOFFSET2_PERCENTAGE
                    mirroredVertically:(self.rank != 7)];
  }
  
  if ((self.rank == 4) || (self.rank == 5) || (self.rank == 6) || (self.rank == 7) || (self.rank== 8) || (self.rank == 9) || (self.rank == 10)) {
    [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                        verticalOffset:PIP_VOFFSET3_PERCENTAGE
                    mirroredVertically:YES];
  }
  
  if ((self.rank == 9) || (self.rank == 10)) {
    [self drawPipsWithHorizontalOffset:PIP_HOFFSET_PERCENTAGE
                        verticalOffset:PIP_VOFFSET1_PERCENTAGE
                    mirroredVertically:YES];

  }
}

#define PIP_FONT_SCALE_FACTOR 0.012

- (void)drawPipsWithHorizontalOffset:(CGFloat)hoffset
                      verticalOffset:(CGFloat)voffset
                          upsideDown:(BOOL)upsideDown
{
  if (upsideDown) [self pushContextAndRotateUpsideDown];
  CGPoint middle = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
  UIFont *pipFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  pipFont = [pipFont fontWithSize:[pipFont pointSize] * self.bounds.size.width * PIP_FONT_SCALE_FACTOR];
  NSAttributedString *attributedSuit = [[NSAttributedString alloc] initWithString:self.suit attributes:@{NSFontAttributeName : pipFont }];
  CGSize pipSize = [attributedSuit size];
  CGPoint pipOrigin = CGPointMake(middle.x - pipSize.width / 2.0 - hoffset * self.bounds.size.width,
                                  middle.y - pipSize.height / 2.0 - voffset * self.bounds.size.height);
  [attributedSuit drawAtPoint:pipOrigin];
  if(hoffset) {
    pipOrigin.x += hoffset * 2.0 * self.bounds.size.width;
    [attributedSuit drawAtPoint:pipOrigin];
  }
  if (upsideDown) [self popContext];
}

- (void)drawPipsWithHorizontalOffset:(CGFloat)hoffset
                      verticalOffset:(CGFloat)voffset
                  mirroredVertically:(BOOL)mirroredVertically
{
  [self drawPipsWithHorizontalOffset:hoffset verticalOffset:voffset upsideDown:NO];
  if(mirroredVertically) {
    [self drawPipsWithHorizontalOffset:hoffset verticalOffset:voffset upsideDown:YES];
  }
  
}

- (void)pushContextAndRotateUpsideDown
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  CGContextTranslateCTM(context, self.bounds.size.width, self.bounds.size.height);
  CGContextRotateCTM(context, M_PI);
}

- (void)popContext
{
  CGContextRestoreGState(UIGraphicsGetCurrentContext());
}


- (NSString *)description
{
   return [NSString stringWithFormat:@"CardView contents: %@%@", [self rankAsString], self.suit];
}


@end
