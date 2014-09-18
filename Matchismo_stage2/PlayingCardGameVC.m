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
#import "Utils.h"

@interface PlayingCardGameVC ()

@end


@implementation PlayingCardGameVC


#pragma mark - Virtual Methods Implementation

#define DEFAULT_NUM_OF_CARDS_IN_PLAYING_CARD_GAME 12
#define NUMBER_OF_CARDS_TO_MATCH_IN_PLAYING_CARD_GAME 2

- (Deck *)createDeck
{
  return [[PlayingCardDeck alloc] init];
}

- (NSUInteger)numOfCardsToMatch {
  return NUMBER_OF_CARDS_TO_MATCH_IN_PLAYING_CARD_GAME;
}

- (NSUInteger)defaultNumOfCardsInGame {
  return DEFAULT_NUM_OF_CARDS_IN_PLAYING_CARD_GAME;
}


- (CardView *)createCardViewWithFrame:(CGRect)frame withCard:(Card *)card;
{
  PlayingCardView *playingCardView = nil;
  
  if ([card isKindOfClass:[PlayingCard class]]) {
    PlayingCard *playingCard = (PlayingCard *)card;
    playingCardView = [[PlayingCardView alloc] initWithFrame:frame withCard:playingCard];
  } else {
    SYSASSERT(NO, @"PlayingCardGameVC: createCardViewWithCard - incompatible parameter type");
  }

  return playingCardView;
}

- (CGFloat)getCardAspectRatio
{
  return [PlayingCardView getCardAspectRatio];
}

@end
