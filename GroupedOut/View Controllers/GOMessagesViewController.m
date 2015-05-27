//
//  GOMessagesViewController.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 5/10/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "GOMessagesViewController.h"
#import "DataStore.h"
#import "Comms.h"

@interface GOMessagesViewController () <JSQMessagesCollectionViewDataSource, JSQMessagesCollectionViewDelegateFlowLayout, CommsDelegate>

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end

@implementation GOMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    self.messages = [[NSMutableArray alloc] init];
    
    self.showLoadEarlierMessagesHeader = YES;
    
    [Comms loginWithFB:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //[Comms getMessagesForEvent:@"hEImhIw46X" forDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commsSendMessageComplete:(BOOL)success {
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
    //[self.collectionView reloadData];
    //[Comms getMessagesForEvent:@"hEImhIw46X" forDelegate:self];
}

- (void)commsDidGetNewMessages:(BOOL)success {
    [self.collectionView reloadData];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    GOMessage *message = [[GOMessage alloc] init];
    message.text = text;
    message.senderDisplayName = senderDisplayName;
    message.senderId = senderId;
    message.isMediaMessage = NO;
    message.date = [NSDate date];
    
    [self.messages addObject:message];
    [self commsSendMessageComplete:YES];
    //[Comms sendMessage:message forEvent:@"hEImhIw46X" forDelegate:self];
}

#pragma mark - JSQMessagesCollectionViewDataSource

- (NSString *)senderId {
    //return [GOUser currentUser].fbId;
    return @"1063931693624048";
}

- (NSString *)senderDisplayName {
    //return [GOUser currentUser].name;
    return @"Charley";
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GOMessage *message = self.messages[indexPath.item];
    return message;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:@"1063931693624048"]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GOMessage *message = self.messages[indexPath.item];
    GOUser *user = [[DataStore instance] userForId:message.senderId];
    
    if (user.profilePicture) {
        return [JSQMessagesAvatarImageFactory avatarImageWithImage:user.profilePicture diameter:34.0];
    }else {
        NSArray* firstLastStrings = [user.name componentsSeparatedByString:@" "];
        char firstInitial = [[firstLastStrings objectAtIndex:0] characterAtIndex:0];
        char lastInitial = [[firstLastStrings objectAtIndex:1] characterAtIndex:0];
        NSString* initials = [NSString stringWithFormat:@"%c%c", firstInitial, lastInitial];
        return [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:initials backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f] textColor:[UIColor colorWithWhite:0.60f alpha:1.0f] font:[UIFont systemFontOfSize:18.0] diameter:34.0];
    }
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
