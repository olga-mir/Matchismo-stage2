//
//  cardGameViewController.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "CardGameViewController.h"
#import "CardMatchingGame.h"
#import "CardView.h"
#import "Grid.h"
#import "Utils.h"

@interface CardGameViewController ()

@property (strong, nonatomic) CardMatchingGame *game;

// grid of cards currently in game
@property (strong, nonatomic) Grid *grid;

// A general view that specifies the bounds of the cards area
@property (weak, nonatomic) IBOutlet UIView *cardsDisplayArea;

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *dealButton;


@end


@implementation CardGameViewController

#pragma mark - Properties
- (CardMatchingGame *)game
{
  if(!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self defaultNumOfCardsInGame]
                                                       usingDeck:[self createDeck]
                                                      cardsInSet:[self numOfCardsToMatch]];
  
  // The game might still be nil if there were not enough cards in the deck.
  // It wouldn't happen in this implementation, because the number of cards for initial game view
  // is much smaller than the cards in the deck.
  return _game;
}

- (Grid *)grid
{
  if (!_grid) {
    NSLog(@"Alloc new grid");
    _grid = [[Grid alloc] init];
    
    _grid.size = self.cardsDisplayArea.frame.size;
    _grid.cellAspectRatio = 0.6;
    _grid.minimumNumberOfCells = [self defaultNumOfCardsInGame];
    
  }
  return _grid;
}

# pragma mark - Lifecycle

- (void)viewDidLoad
{
  NSLog(@"CardGameVC: viewDidLoad");
  
  [super viewDidLoad];
  
  // Update the grid
  self.grid.size = self.cardsDisplayArea.frame.size; // it could change due to rotate
  self.grid.minimumNumberOfCells = self.game.curNumberOfCardsInGame;
  //self.grid.cellAspectRatio = // TODO - get ratio per Set/Playing class
  NSLog(@"CardGameVC: self.game.curNumberOfCardsInGame: %d", self.game.curNumberOfCardsInGame);
  NSLog(@"%@", self.grid);
  
  SYSASSERT(self.grid.inputsAreValid, @"Can't layout the views because grid inputs are invalid"); // TODO - temp. do something sensible later

  [self.cardsDisplayArea setBackgroundColor:[UIColor blackColor]];
  //self.cardsDisplayArea.alpha = 1;
//  self.cardsDisplayArea.opaque = YES;
  self.cardsDisplayArea.userInteractionEnabled = NO;
  
  
  
    // populate the grid with the card views
    for (int c = 0; c < self.game.curNumberOfCardsInGame; c++) {
      
//      CGFloat x = 0;
//      CGFloat y = 0;
      
      CGRect frame;
      frame.origin = CGPointZero;
      frame.size = self.grid.cellSize;
      
      Card *card = [self.game cardAtIndex:c];
      CardView *cardView = [self createCardViewWithFrame:frame withCard:card];
      
      //    [cardView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:cardView action:@selector(swipe:)]];
      
      cardView.opaque = YES;
      [self.cardsDisplayArea addSubview:cardView];
      
      frame.origin.x += 80;
      UIView *v = [[UIView alloc] initWithFrame:frame];
      [v setBackgroundColor:[UIColor redColor]];
      v.opaque = YES;
      [self.cardsDisplayArea addSubview:v];
      
    }
/*
  CGRect frame;
  frame.origin = CGPointZero;
  frame.origin.x += 80;
  UIView *v = [[UIView alloc] initWithFrame:frame];
  [v setBackgroundColor:[UIColor redColor]];
  [self.cardsDisplayArea addSubview:v];
 */

 
//CGSize cellSize;        // will be made as large as possible
//NSUInteger rowCount;
//NSUInteger columnCount;
    
    // origin row and column are zero
    
//- (CGPoint)centerOfCellAtRow:(NSUInteger)row inColumn:(NSUInteger)column;
//- (CGRect)frameOfCellAtRow:(NSUInteger)row inColumn:(NSUInteger)column;
  
}

#pragma mark - User Interface

// at this stage the deal button doesn't prompt the user if he really intends to drop current game
- (IBAction)touchDealButton:(id)sender
{
  NSLog(@"DEAL - in the main VC");
  [self.game restartGame];
  [self updateUI];
}


- (IBAction)swipe:(UISwipeGestureRecognizer *)sender {
  
  int chosenCardIndex = [self.cardsDisplayArea.subviews indexOfObject:sender];
  
  CardView *cardView = [self.cardsDisplayArea.subviews objectAtIndex:chosenCardIndex];
  cardView.faceUp = !cardView.faceUp;
  
  NSLog(@"Chose card at index: %d", chosenCardIndex);
  [self.game choseCardAtIndex:chosenCardIndex];
}


/*
- (IBAction)touchCardButton:(id)sender
{
  NSLog(@"Touch card button");
  int chosenCardButtonIndex = [self.cardButtons indexOfObject:sender];
  NSLog(@"Chose card at index: %d", chosenCardButtonIndex);
  [self.game choseCardAtIndex:chosenCardButtonIndex];
  [self updateUI];
}
*/

- (void) updateUI
{/*
  for (UIButton *cardButton in self.cardButtons) {
    int cardButtonIndex = [self.cardButtons indexOfObject:cardButton];
    Card *card = [self.game cardAtIndex:cardButtonIndex];
    [cardButton setTitle:[self titleForCard:card] forState:UIControlStateNormal];
    [cardButton setBackgroundImage:[self backgroundImageForCard:card] forState:UIControlStateNormal];
    cardButton.enabled = !card.isMatched;
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.game.score];

  }*/
}

- (NSString *)titleForCard:(Card *)card
{
  // This is temporary stage function
  return card.isChosen ? @"??" : @"";
}

- (UIImage *)backgroundImageForCard:(Card *)card
{
  return [UIImage imageNamed:card.isChosen ? @"cardfront" : @"cardback"];
}



#pragma mark - Virtual Methods
// Used throw exception mechanism in order to enforce the abstracness of these methods.
// Use of protocol or compiler warnings like __attribute__((unavailable(msg)))
// will result in compile time error (which is good),
// but will prevent from calling these functions in this base class.
// Since this "error" must be handled and fixed in development stage
// it is appropriate here to use an assertion or throw an exception.
// The exception is preferrable though, because in this case there is
// no need in return statement that would be more of a workaround
- (Deck *)createDeck
{
  mustOverride();
}

- (NSUInteger)numOfCardsToMatch
{
  mustOverride();
}

- (NSUInteger)defaultNumOfCardsInGame
{
  mustOverride();
}

- (CardView *)createCardViewWithFrame:(CGRect)frame withCard:(Card *)card
{
  mustOverride();
}
 

@end


