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
@property (strong, nonatomic) NSMutableArray *cardViews; // of CardView's

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel; // TODO - not yet implemented
@property (weak, nonatomic) IBOutlet UIButton *dealButton;

@end


// TODO - not yet implemented - when gameInProgress - use KVO. don't try to do graphics when cards are all gone
// TODO - game over. all matched or remaining cards could not be matched
// TODO - disable user interaction while animating
// TODO - On Set cards black corner show through
// TODO - Deal button, score label doesn't appear on the set game screen, and when returning to the playing card game they also disappear

@implementation CardGameViewController

#pragma mark - Properties

- (CardMatchingGame *)game
{
  if(!_game) _game = [[CardMatchingGame alloc] initWithCardCount:[self defaultNumOfCardsInGame]
                                                       usingDeck:[self createDeck]
                                                      cardsInSet:[self numOfCardsToMatch]];
  
  // The game might still be nil if there were not enough cards in the deck.
  // It wouldn't happen in this implementation, because the number of cards
  // in the beginning of the game is much smaller than the cards in the deck.
  return _game;
}

- (NSMutableArray *)cardViews
{
  if (!_cardViews) _cardViews = [[NSMutableArray alloc] init];
  return _cardViews;
}

- (Grid *)grid
{
  if (!_grid) _grid = [[Grid alloc] init];
  return _grid;
}

#pragma mark - User Interaction
// The card views will not handle user's gestures.
// The gestures will be handled by the game controller since only the view controller
// has the connection between the cards in the game which is held by model and every individual card view
// Other options could be storing the card index at the view, which is bad because it mixes the view with model
// or the view could notify the VC of its value. But that will make it impossible to use
// for a game with two identical decks or for a deck with two or more sets of identical cards in it
// TODO - see if view.tag can help
- (void)tap:(UITapGestureRecognizer *)tapGesture
{
  NSLog(@"Tap gesture recognizer in main VC");
  
  CGPoint tapLocation = [tapGesture locationInView:self.cardsDisplayArea];
  
  NSUInteger row = tapLocation.y / self.grid.cellSize.height;
  NSUInteger col = tapLocation.x / self.grid.cellSize.width;
  NSUInteger visibleCardIndex = row * self.grid.columnCount + col;
  
  // visibleCardIndex is the index of the card view which received this gesture. It is index in
  // the GRID. But cards in game model and in VC array of views are not removed after the match, they are simply hidden
  // So the index in the grid must be offset by the number of hidden card views, before this particular index,
  // to represent the actual card index held by the game logic
  NSUInteger chosenCardIndex = visibleCardIndex; // it is at least a visibleCardIndex
  NSUInteger visibleCards = 0;
  
  if (chosenCardIndex >= self.game.curNumberOfCardsInGame) {
    NSLog(@"Touched outside visible cards - doing nothing");
    return;
  }
  

  for (int i = 0; i <= [self.cardViews count]; i++) {
    if (![self.cardViews[i] isHidden]) {
      visibleCards++;
    }
    
    if (visibleCards == visibleCardIndex + 1) {
      chosenCardIndex = i;
      break;
    }
  }
  NSLog(@"index translation: visibleCardIndex = %d, chosenCardIndex = %d", visibleCardIndex, chosenCardIndex);
  
  CardView *cardView = [self.cardViews objectAtIndex:chosenCardIndex];

  // Change the card view appearance.
  // It should flip over for the Playing card view or make a selected/de-selected appearance for the Set card
  [cardView selectOrDeselectCard];
  
  // Notify the model about the user's selection and perform the game logic
  [self.game choseCardAtIndex:chosenCardIndex];
  
  // Show the result of this interaction to the user.
  // Possible results:
  // 1. There is not yet enough cards to make the match =>
  //    no visible changes except for the flipping/selecting card, which was already doen
  // 2. There was a match => remove cards, update score, reposition the remaining cards
  // 3. There was no match => de-select chosen cards or flip them over to face down

  [self animateMatchOutcome];
}

// Called after the current current card selection was processed
// The current state can be one of:
// 1. the match is not yet completed (in 2-card-matching only one card is currently selected)
//    In this case no changes will be detected in this function and there will be no animations
// 2. the match was completed and resolved -
//    a) the cards didn't match => the isChosen state has changed and the card must be flipped over, to face down state
//    b) the cards match => the both cards should dissappear and the rest of the cards must be moved to utilize the space efficiently
- (void)animateMatchOutcome
{
  // First find the views that need to change appearance then animate the appropriate change
  NSMutableArray *cardsToHide     = [[NSMutableArray alloc] init];
  NSMutableArray *cardsToDeselect = [[NSMutableArray alloc] init];

  for (int i = 0; i < [self.cardViews count]; i++) {
    
    // get a card from the model and its corresponding view
    // Both game model and the cardViews hold all the cards that are/were in the game
    // The cards that previously been matched are not shown
    // This implementation makes game logic simplier and adheres to the assignment recommendation
    Card *card = [self.game cardAtIndex:i];
    CardView *cardView = self.cardViews[i];
    
    // Model ('card') already holds the next game state, while the View is only being updated right now
    // so 'card' is the next state and 'cardView' is the current state
    if (card.isMatched != cardView.hidden) {
      [cardsToHide addObject:cardView];
    }
    
    if (card.isChosen != [cardView getSelectedState]) { // faceUp for the Playing card and isSelected for Set card
      [cardsToDeselect addObject:cardView];
    }
  }
  
  // Update the selected states of the cards that in this cycle changed this state
  [cardsToDeselect makeObjectsPerformSelector:@selector(selectOrDeselectCard)];
  
  // hide the cards and reposition the remaining if needed
  if ([cardsToHide count]) {
    [self hideCards:cardsToHide];
    [self rePositionCards];
  }
}

// Hides the cards in the 'cardsToHide' array while animating the change
- (void)hideCards:(NSArray *)cardsToHide
{
  for (CardView *cardView in cardsToHide) {
    [UIView transitionWithView:cardView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                      cardView.hidden = YES;
                    }
                    completion:NULL];
    
  }
}


- (void)rePositionCards
{
  // re-arrange cards to take all the available screen space
  [self gridSetup];
  
  NSUInteger currVisibleInd = 0;
  
  for (NSUInteger currInd = 0; currInd < [self.cardViews count]; currInd++) {
    
    CardView *cardView = self.cardViews[currInd];
    
    if (!cardView.isHidden) {
      
      CGRect frame = [self setupFrameAtIndex:currVisibleInd];
      
      currVisibleInd++;
      
      // Animate changes in the frame (it there were any)
      if ([self isDifferentFrame:frame anotherFrame:cardView.frame]) {
        
        [UIView transitionWithView:cardView
                          duration:0.6
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                          cardView.frame = frame;
                        }
                        completion:nil];
      }
    }
  }
}

// TODO - research how to compare frames, or work with floats make params pass by const reference.
- (BOOL)isDifferentFrame:(CGRect)frame anotherFrame:(CGRect)anotherFrame
{
  BOOL differentFrame = NO;
  
  // the frame of a card can change as a result of the current match in two cases:
  // 1. the rest of the cards have to move to cover the spaces. The frame will have different origin.
  // 2. the last row had been cleared out, and there is more space for each of the rest of the cards. The frame will be bigger.
  
  // case 1. NB: it will be sufficient in this implementation to test only the x component
  if ((abs(frame.origin.x - anotherFrame.origin.x) > 0.00001) ||
      (abs(frame.origin.y - anotherFrame.origin.y) > 0.00001)) {
    differentFrame = YES;
  
  // case 2. Since cards are proportional in the game it is sufficient to check one (any) dimension
  } else if (abs(frame.size.height - anotherFrame.size.height) > 0.00001) {
    differentFrame = YES;
  }
  return differentFrame;
}

- (void)gridSetup
{
  self.grid.size = self.cardsDisplayArea.frame.size; // it could change due to rotate
  self.grid.minimumNumberOfCells = [self.game curNumberOfCardsInGame];
  self.grid.cellAspectRatio = [CardView getAspectRatio];

  
  NSLog(@"%@", self.grid);
  
  SYSASSERT(self.grid.inputsAreValid, @"Can't layout the views because grid inputs are invalid"); // TODO - temp. do something sensible later
}

#define CARD_VIEW_SCALE_FACTOR 0.97

- (void)viewDidLoad
{
  NSLog(@"CardGameVC: viewDidLoad");
  
  [super viewDidLoad];
  
  [self.cardsDisplayArea setBackgroundColor:[UIColor clearColor]]; // the view has alpha 1 and clearColor, so that the subviews will be visible
  
  // The card views will not handle user's gestures.
  // The gestures will be handled by the game controller since only the view controller
  // has the connection between the cards in the game which is held by model and every individual card view
  // see the tap gesture handler in this VC for more explanation about this implementation decision
  [self.cardsDisplayArea addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
  
  [self createCardViews];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  [self gridSetup];
  [self rePositionCards];
}

- (void)createCardViews
{
  // first of all - set up the grid. The grid will affect the cards size.
  [self gridSetup];

  for (int cardInd = 0; cardInd < self.game.curNumberOfCardsInGame; cardInd++) {
    
    CGRect frame = [self setupFrameAtIndex:cardInd];
    
    Card *card = [self.game cardAtIndex:cardInd];
    SYSASSERT((card), @"Card Should not be nil");
    
    CardView *cardView = [self createCardViewWithFrame:frame withCard:card];
    SYSASSERT((cardView), @"CardView should not be nil");
    
    [self.cardViews addObject:cardView];
    [self.cardsDisplayArea addSubview:cardView];
  }
}

- (CGRect)setupFrameAtIndex:(int)cardInd // TODO - by reference?
{
  NSUInteger r = cardInd / self.grid.columnCount;
  NSUInteger c = cardInd % self.grid.columnCount;
  
  CGRect gridCell = [self.grid frameOfCellAtRow:r inColumn:c];
  
  // frames provided by grid take all the available space, so the frame for the card view
  // should be scalled a little in order to provide some spacing between them
  CGRect frame;
  frame.size.width  = gridCell.size.width * CARD_VIEW_SCALE_FACTOR;
  frame.size.height = gridCell.size.height * CARD_VIEW_SCALE_FACTOR;
  
  // Also the frame must be positioned in the center of the grid cell
  frame.origin.x = gridCell.origin.x + (gridCell.size.height - frame.size.height) / 2;
  frame.origin.y = gridCell.origin.y + (gridCell.size.width - frame.size.width) / 2;
  
  return frame;
}

#pragma mark - User Interface

// at this stage the deal button doesn't prompt the user if he really intends to drop current game
// TODO - animate departure of old cards and arrival of new ones
- (IBAction)touchDealButton:(id)sender
{
  NSLog(@"DEAL - in the main VC");
  
  [self.game restartGame];
  
  [self.cardViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.cardViews removeAllObjects];
  [self createCardViews];
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


