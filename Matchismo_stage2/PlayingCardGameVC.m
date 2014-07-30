//
//  PlayingCardGameVC.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "PlayingCardGameVC.h"
#import "PlayingCardDeck.h"
#import "PlayingCardView.h"
#import "PlayingCard.h"

@interface PlayingCardGameVC ()

@end


@implementation PlayingCardGameVC

- (instancetype)init
{
  NSLog(@"PlayingCardGameVC: init");
  self = [super init];
  return self;
}

- (void)viewDidLoad
{
  NSLog(@"PlayingCardGameVC: viewDidLoad");
  
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Virtual Methods Implementation

#define DEFAULT_NUM_OF_CARDS_IN_PLAYING_CARD_GAME 12
#define NUMBER_OF_CARDS_TO_MATCH_IN_PLAYING_CARD_GAME 2

- (Deck *)createDeck
{
  NSLog(@"PlayingCardGameVC: createDeck");
  return [[PlayingCardDeck alloc] init];
}

- (NSUInteger)numOfCardsToMatch {
  NSLog(@"PlayingCardGameVC: set num of cards to match (2 for the playing card game)");
  return NUMBER_OF_CARDS_TO_MATCH_IN_PLAYING_CARD_GAME;
}

- (NSUInteger)defaultNumOfCardsInGame {
  NSLog(@"PlayingCardGameVC: defaultNumOfCardsInGame");
  return DEFAULT_NUM_OF_CARDS_IN_PLAYING_CARD_GAME;
}


- (CardView *)createCardViewWithFrame:(CGRect)frame withCard:(Card *)card;
{
  PlayingCardView *playingCardView = nil;
  
  if ([card isKindOfClass:[PlayingCard class]]) {
    PlayingCard *playingCard = (PlayingCard *)card;
    playingCardView = [[PlayingCardView alloc] initWithFrame:frame withCard:playingCard];
  } else {
    // TODO - exception
    NSLog(@"PlayingCardGameVC: createCardViewWithCard - incompatible parameter type");
  }

  return playingCardView;
}

// default aspect ratio of the playing card ("Poker" type) - 56/88
#define DEFAULT_PLAYING_CARD_ASPECT_RATIO 0.625

- (CGFloat)getCardAspectRatio
{
  return DEFAULT_PLAYING_CARD_ASPECT_RATIO;
}


@end
