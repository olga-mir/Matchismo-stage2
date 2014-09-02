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
@property (weak, nonatomic) IBOutlet UIButton *dealMoreCardsButton;

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


#pragma mark - Lifecycle

- (void)viewDidLoad
{
  NSLog(@"CardGameVC: viewDidLoad");
  
  [super viewDidLoad];
  
  [self.cardsDisplayArea setBackgroundColor:[UIColor clearColor]]; // the view has alpha 1 and clearColor, so that the subviews will be visible
  
  NSLog(@"self.displayArea size: (%f, %f)", self.cardsDisplayArea.frame.size.width, self.cardsDisplayArea.frame.size.height);
  
  // The card views do not handle user's gestures.
  // The gestures are handled by the game controller since only the view controller
  // has the connection between the cards in the game which is held by Model and every individual card view in the View
  // see the tap gesture handler in this VC for more explanation about this implementation decision
  [self.cardsDisplayArea addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
  
  [self createCardViews];

  [self.game addObserver:self forKeyPath:@"moreMatchesAvailable" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  [self rePositionCards];
}

#pragma mark - Creating Card Views

#define CARD_VIEW_SCALE_FACTOR 0.97

/**
 *  Create the CardViews - array of Card views. This array holds the maximum value of cards that has ever been in the current game i.e. if the game started with 12 cards and then at some point user requested 3 more cards, then this array will hold 15 UIViews objects no matter how many matches have been discovered since then. Some of these Views will eventually be hidden
 */
- (void)createCardViews
{
  [self addViewForCardsFromIndex:0 toIndex:(self.game.curNumberOfCardsInGame - 1)];
}

- (void)addViewForCardsFromIndex:(NSUInteger)fromInd toIndex:(NSUInteger)toInd
{
  NSLog(@"fromInd = %d, toInd = %d", fromInd, toInd);
  
  // The grid will affect the cards size so it must be setup before constructing new CardView objects
  [self gridSetup];
  
  for (NSUInteger cardInd = fromInd; cardInd <= toInd; cardInd++) {
    
    // Only on the first time when creating the views don't translate indexes
    NSUInteger gridIndex = ([self.cardViews count]) ? [self translateToGameIndexFromVisibleIndex:cardInd] : cardInd;
    
    CGRect frameFinalPosition = [self setupFrameAtIndex:gridIndex];
    //CGRect frameTempPosition = frameFinalPosition;
    //frameTempPosition.origin = CGPointMake(500.0, 500.0);
    
    Card *card = [self.game cardAtIndex:cardInd];
    SYSASSERT(card, @"Card should not be nil");
    
    CardView *cardView = [self createCardViewWithFrame:frameFinalPosition withCard:card];
    SYSASSERT(cardView, @"CardView should not be nil");
    
    [self.cardViews addObject:cardView];
    [self.cardsDisplayArea addSubview:cardView];
    NSLog(@"Added at the index %d: CardView - %@, Card - %@", cardInd, cardView.contents, card.contents);
/*
    
    [UIView transitionWithView:cardView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                      cardView.frame = frameFinalPosition;
                    }
                    completion:^(BOOL finished){
                      
                    }];
  */
  }
}

// Create a frame for a card at the given index, according to the current grid
- (CGRect)setupFrameAtIndex:(int)cardInd // TODO - by reference?
{
  NSUInteger r = cardInd / self.grid.columnCount;
  NSUInteger c = cardInd % self.grid.columnCount;
  
  CGRect gridCell = [self.grid frameOfCellAtRow:r inColumn:c];
  
  // frames provided by grid take all the available space, so the frame for the card view
  // should be scaled a little in order to provide some spacing between them
  CGRect frame;
  frame.size.width  = gridCell.size.width * CARD_VIEW_SCALE_FACTOR;
  frame.size.height = gridCell.size.height * CARD_VIEW_SCALE_FACTOR;
  
  // Also the frame must be positioned in the center of the grid cell
  frame.origin.x = gridCell.origin.x + (gridCell.size.height - frame.size.height) / 2;
  frame.origin.y = gridCell.origin.y + (gridCell.size.width - frame.size.width) / 2;
  
  return frame;
}


/**
 *  Setup the grid inputs. Grid is based on 3 inputs: size, aspect ration and number of cells. During the game any of this can change and therefore the grid should be updated in the appropriate places in the code. For example card removal due to match, adding more cards. 
 */
- (void)gridSetup
{
  self.grid.size = self.cardsDisplayArea.frame.size;
  self.grid.minimumNumberOfCells = [self.game curNumberOfCardsInGame];
  self.grid.cellAspectRatio = [CardView getAspectRatio];
  
  NSLog(@"%@", self.grid);
  
  SYSASSERT(self.grid.inputsAreValid, @"Can't layout the views because grid inputs are invalid");
}



#pragma mark - Outlets

// at this stage the deal button doesn't prompt the user if he really intends to drop current game
// TODO - animate departure of old cards and arrival of new ones
- (IBAction)touchDealButton:(id)sender
{
  NSLog(@"DEAL - in the main VC");
  
  // reset the model
  [self.game restartGame];
  
  // reset the controller
  [self.cardViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self.cardViews removeAllObjects];
  
  // this will also reset the grid
  [self createCardViews];
}


/**
 *  UI outlet to let user request more cards to be added to the current game.
 *
 *  @param sender sender is the button that triggered this handler. It is not used.
 */
- (IBAction)touchDealMoreCardsButton:(UIButton *)sender
{
  NSUInteger prevNumOfCards = [self.cardViews count];
  
  [self.game addCardsToPlay:[self numOfCardsToMatch]];
  
  [self addViewForCardsFromIndex:prevNumOfCards toIndex:[self.cardViews count] + [self numOfCardsToMatch] - 1];
  [self rePositionCards];
}


/**
 *  Tap gesture recogniser. The gestures are handled by the game controller since only the VC has the connection between the cards in the game which is held by model and every individual card view.
 *
 *  @param tapGesture the sender of the event
 */
- (void)tap:(UITapGestureRecognizer *)tapGesture
{
  CGPoint tapLocation = [tapGesture locationInView:self.cardsDisplayArea];
  
  NSUInteger row = tapLocation.y / self.grid.cellSize.height;
  NSUInteger col = tapLocation.x / self.grid.cellSize.width;
  NSUInteger visibleCardIndex = row * self.grid.columnCount + col;
  
  if (visibleCardIndex >= self.game.curNumberOfCardsInGame) {
    NSLog(@"Touched outside visible cards - ingnoring the touch");
    return;
  }
  
  NSUInteger chosenCardIndex = [self translateToGameIndexFromVisibleIndex:visibleCardIndex];
  
  CardView *cardView = [self.cardViews objectAtIndex:chosenCardIndex];
  NSLog(@"cardView: %@", cardView);

  // Change the card view appearance.
  // It should flip over for the Playing card view or make a selected/de-selected appearance for the Set card
  [cardView selectOrDeselectCard];
  
  // Notify the model about the user's selection and perform the game logic
  //[self.game choseCardAtIndex:chosenCardIndex];
  Card *card = [self.game debugWrapper_choseCardAtIndex:chosenCardIndex];
  if (![cardView.contents isEqual:card.contents]) {
    NSString *msg = [NSString stringWithFormat:@"Inconsistensy in Model and View indexes! Index: chosenCardIndex, View: %@, Model: %@", cardView.contents, card.contents];
    SYSASSERT(NO, msg);
  }
  
  // Show the result of this interaction to the user.
  // Possible results:
  // 1. There is not yet enough cards to make the match =>
  //    no visible changes except for the flipping/selecting card, which was already doen
  // 2. There was a match => remove cards, update score, reposition the remaining cards
  // 3. There was no match => de-select chosen cards or flip them over to face down

  [self animateMatchOutcome];
}


/**
 *  Translate index from the game model logic which holds all the cards that ever were dealt in this game, in their original order to the grid of the visible cards only. Index in the grid is calculated from the tap gesture recogniser, to translate it to the game logic index the visible index must be offset by amount of the hidden cards upto this particular index
 *
 *  @param visibleCardIndex index in the grid of visible cards
 *
 *  @return index in the game array of cards
 */
- (NSUInteger)translateToGameIndexFromVisibleIndex:(NSUInteger)visibleCardIndex
{
  NSUInteger chosenCardIndex = visibleCardIndex; // it is at least a visibleCardIndex
  NSUInteger visibleCards = 0;
  
  SYSASSERT([self.cardViews count], @"CardViews array is empty - nothing to translate");
  
  for (int i = 0; i < [self.cardViews count]; i++) {
    if (![self.cardViews[i] isHidden]) {
      visibleCards++;
    }
    
    if (visibleCards == visibleCardIndex + 1) {
      chosenCardIndex = i;
      break;
    }
  }
  NSLog(@"index translation: visibleCardIndex = %d, chosenCardIndex = %d", visibleCardIndex, chosenCardIndex);
  
  return chosenCardIndex;
}


/**
 *  This function is called after the current match has been resolved. The match can lead to one of the following states:
  1. the match is not yet completed (in 2-card-matching only one card is currently selected)
     In this case no changes will be detected in this function and there will be no animations
  2. the match was completed and resolved -
     a) the cards didn't match => the isChosen state has changed and the card must be flipped over, to face down state
     b) the cards match => the both cards should dissappear and the rest of the cards must be moved to utilize the space efficiently

 */
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
  
  // Update the selected states of the cards that changed their state in this cycle
  [cardsToDeselect makeObjectsPerformSelector:@selector(selectOrDeselectCard)];
  
  // hide the cards and reposition the remaining if needed
  if ([cardsToHide count]) {
    [self hideCards:cardsToHide];
  }
}


/**
 *  Hides the cards in the given array while animating this change. After the CardViews ahd dissapear from the screen the rest of the cards should reposition themself
 *
 *  @param cardsToHide array of cardViews that need to be hidden
 */
- (void)hideCards:(NSArray *)cardsToHide
{
  for (CardView *cardView in cardsToHide) {
    [UIView transitionWithView:cardView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                      cardView.hidden = YES;
                    }
                    completion:^(BOOL finished){
                      [self rePositionCards];
                    }];
    
  }
}


/**
 *  Recalculate the size and the position of the cards that are currently in the game. After number of cards had
 */
- (void)rePositionCards
{
  // re-arrange cards to take all the available screen space
  [self gridSetup];
  
  NSUInteger currVisibleInd = 0;
  
  // Interate over all cardView Views and animate frame change for visible cardViews
  for (NSUInteger currInd = 0; currInd < [self.cardViews count]; currInd++) {
    
    CardView *cardView = self.cardViews[currInd];
    
    if (!cardView.isHidden) {
      
      // get the current frame new origin and size according to the grid
      CGRect frame = [self setupFrameAtIndex:currVisibleInd];
      
      currVisibleInd++;
      
      // if frame has changed (both position or size) animate this change
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

/**
 *  Observe value for the game over indication from the model.
 *
 *  @param keyPath keyPath for the key indicating game over state in the model
 *  @param object  not used
 *  @param change  change is replacement of the old value with the new one
 *  @param context not used
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ((object == _game) && ([keyPath isEqual:@"moreMatchesAvailable"])) {
    if ([[change objectForKey:NSKeyValueChangeNewKey] integerValue] == 0) { // new value of 'moreMatchesAvailable' is 0
      [self gameOver];
    }
  }
}


/**
 *  Notify user that the current game is over.
 */
- (void)gameOver
{
  // No matches can be done with the remaining cards
  NSLog(@"GAME OVER!");
  
  // TODO - before removing the cards, first flip them over to show that there are no matches
  // TODO - set game over message, create deal button below it and hide the deal button in its original position
  
  // Remove all remaining visible cards from the board
  NSMutableArray *cardsToHide = [[NSMutableArray alloc] init];
  for (CardView *cv in self.cardViews) {
    if (!cv.isHidden) {
      [cardsToHide addObject:cv];
    }
  }
  [self hideCards:cardsToHide];
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


