//
//  WLButtonAreaHotspotHandler.m
//  Welly
//
//  Created by K.O.ed on 09-1-27.
//  Copyright 2009 Welly Group. All rights reserved.
//

#import "WLButtonAreaHotspotHandler.h"
#import "WLMouseBehaviorManager.h"

#import "WLTerminalView.h"
#import "WLConnection.h"
#import "WLTerminal.h"

#define fbComposePost @"\020"
#define fbDeletePost @"dy\n"
#define fbShowNote @"\t"
#define fbShowHelp @"h"
#define fbNormalToDigest @"\07""1\n"
#define fbDigestToThread @"\07""2\n"
#define fbThreadToMark @"\07""3\n"
#define fbMarkToOrigin @"\07""4\n"
#define fbOriginToNormal @"e"
#define fbSwitchDisplayAllBoards @"y"
#define fbSwitchSortBoards @"S"
#define fbSwitchBoardsNumber @"c"

NSString *const WLButtonNameComposePost = @"Compose Post";
NSString *const WLButtonNameDeletePost = @"Delete Post";
NSString *const WLButtonNameShowNote = @"Show Note";
NSString *const WLButtonNameShowHelp = @"Show Help";
NSString *const WLButtonNameNormalToDigest = @"Normal To Digest";
NSString *const WLButtonNameDigestToThread = @"Digest To Thread";
NSString *const WLButtonNameThreadToMark = @"Thread To Mark";
NSString *const WLButtonNameMarkToOrigin = @"Mark To Origin";
NSString *const WLButtonNameOriginToNormal = @"Origin To Normal";
NSString *const WLButtonNameAuthorToNormal = @"Author To Normal";
NSString *const WLButtonNameJumpToMailList = @"Jump To Mail List";
NSString *const WLButtonNameEnterExcerption = @"Enter Excerption";

NSString *const WLButtonNameSwitchDisplayAllBoards = @"Display All Boards";
NSString *const WLButtonNameSwitchSortBoards = @"Sort Boards";
NSString *const WLButtonNameSearchBoards = @"Search Boards";
NSString *const WLButtonNameSwitchBoardsNumber = @"Switch Boards Number";
NSString *const WLButtonNameAddBoard = @"Add Board";
NSString *const WLButtonNameAddDirectory = @"Add Directory";
NSString *const WLButtonNameMoveBoard = @"Move Board";
NSString *const WLButtonNameDeleteBoard = @"Delete Board";

NSString *const WLButtonNameChatWithUser = @"Chat";
NSString *const WLButtonNameMailToUser = @"Mail";
NSString *const WLButtonNameSendMessageToUser = @"Send Message";
NSString *const WLButtonNameShowUserInfo = @"Show User Info";
NSString *const WLButtonNameAddUserToFriendList = @"Add To Friend List";
NSString *const WLButtonNameRemoveUserFromFriendList = @"Remove From Friend List";
NSString *const WLButtonNameSwitchUserListMode = @"Switch User List Mode";
NSString *const WLButtonNameShowUserDescription = @"Show User Description";
NSString *const WLButtonNamePreviousUser = @"Previous User";
NSString *const WLButtonNameNextUser = @"Next User";
NSString *const WLButtonNameShowUserBoards = @"Show User Boards";
NSString *const WLButtonNameSendSMSToUser = @"Send SMS";

NSString *const WLButtonNameRetainMessages = @"Retain Messages";
NSString *const WLButtonNameClearMessages = @"Clear Messages";
NSString *const WLButtonNameMailMessages = @"Mail Messages";
NSString *const WLButtonNameSearchID = @"Search ID";
NSString *const WLButtonNameSearchMessages = @"Search Messages";
NSString *const WLButtonNameShowAllMessages = @"Show All Messages";

NSString *const FBCommandSequenceAuthorToNormal = @"e";
NSString *const FBCommandSequenceSearchBoards = @"/";
NSString *const FBCommandSequenceAddBoard = @"a";
NSString *const FBCommandSequenceAddDirectory = @"A";
NSString *const FBCommandSequenceMoveBoard = @"m";
NSString *const FBCommandSequenceChatWithUser = @"t";
NSString *const FBCommandSequenceMailToUser = @"m";
NSString *const FBCommandSequenceSendMessageToUser = @"s";
NSString *const FBCommandSequenceShowUserInfo = @"i";
NSString *const FBCommandSequenceAddUserToFriendListA = @"a";
NSString *const FBCommandSequenceAddUserToFriendListO = @"oY\n";
NSString *const FBCommandSequenceRemoveUserFromFriendList = @"dY\n";
NSString *const FBCommandSequenceSwitchUserListModeC = @"c";
NSString *const FBCommandSequenceSwitchUserListModeF = @"f";
NSString *const FBCommandSequenceShowUserDescriptionL = @"l";
NSString *const FBCommandSequenceShowUserDescriptionV = @"v";
NSString *const FBCommandSequencePreviousUser = termKeyUp;
NSString *const FBCommandSequenceNextUser = termKeyDown;
NSString *const FBCommandSequenceJumpToMailList = @"v";
NSString *const FBCommandSequenceEnterExcerption = @"x";
NSString *const FBCommandSequenceShowUserBoards = @"k";
NSString *const FBCommandSequenceSendSMSToUser = @"w";
NSString *const FBCommandSequenceRetainMessages = @"r";
NSString *const FBCommandSequenceClearMessages = @"c";
NSString *const FBCommandSequenceMailMessages = @"m";
NSString *const FBCommandSequenceSearchID = @"i";
NSString *const FBCommandSequenceSearchMessages = @"s";
NSString *const FBCommandSequenceShowAllMessages = @"a";

@implementation WLButtonAreaHotspotHandler
#pragma mark -
#pragma mark Mouse Event Handler
- (void)mouseUp:(NSEvent *)theEvent {
    NSString *commandSequence = _manager.activeTrackingAreaUserInfo[WLMouseCommandSequenceUserInfoName];
    if (commandSequence != nil) {
        [_view.frontMostConnection sendText:commandSequence];
        return;
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    NSDictionary *userInfo = theEvent.trackingArea.userInfo;
    if (_view.isMouseActive) {
        NSString *buttonText = userInfo[WLMouseButtonTextUserInfoName];
        [_view drawButton:theEvent.trackingArea.rect withMessage:buttonText];
    }
    _manager.activeTrackingAreaUserInfo = userInfo;
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [_view clearButton];
    [_manager setActiveTrackingAreaUserInfo:nil];
    // FIXME: Temporally solve the problem in full screen mode.
    if ([NSCursor currentCursor] == [NSCursor pointingHandCursor])
        [_manager restoreNormalCursor];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if ([NSCursor currentCursor] != [NSCursor pointingHandCursor])
        [[NSCursor pointingHandCursor] set];
}

#pragma mark -
#pragma mark Update State
- (void)addButtonArea:(NSString *)buttonName
      commandSequence:(NSString *)cmd
                atRow:(int)r
               column:(int)c
               length:(int)len {
    NSRect rect = [_view rectAtRow:r column:c height:1 width:len];
    // Generate User Info
    NSArray *keys = @[WLMouseHandlerUserInfoName, WLMouseCommandSequenceUserInfoName, WLMouseButtonTextUserInfoName];
    NSArray *objects = @[self, cmd, NSLocalizedString(buttonName, @"Mouse Button")];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    [_trackingAreas addObject:[_manager addTrackingAreaWithRect:rect userInfo:userInfo]];
}

- (void)updateButtonAreaForRow:(int)r {
    const WLButtonDescription buttonsDefinition[] = {
        /* BBSBrowseBoard */
        {BBSBrowseBoard, @"发表文章[Ctrl-P]", 16, WLButtonNameComposePost, fbComposePost},
        {BBSBrowseBoard, @"砍信[d]", 7, WLButtonNameDeletePost, fbDeletePost},
        {BBSBrowseBoard, @"备忘录[TAB]", 11, WLButtonNameShowNote, fbShowNote},
        {BBSBrowseBoard, @"求助[h]", 7, WLButtonNameShowHelp, fbShowHelp},
        {BBSBrowseBoard, @"[一般模式]", 10, WLButtonNameNormalToDigest, fbNormalToDigest},
        {BBSBrowseBoard, @"[文摘模式]", 10, WLButtonNameDigestToThread, fbDigestToThread},
        {BBSBrowseBoard, @"[主题模式]", 10, WLButtonNameThreadToMark, fbThreadToMark},
        {BBSBrowseBoard, @"[精华模式]", 10, WLButtonNameMarkToOrigin, fbMarkToOrigin},
        {BBSBrowseBoard, @"[原作模式]", 10, WLButtonNameOriginToNormal, fbOriginToNormal},
        {BBSBrowseBoard, @"[作者模式]", 10, WLButtonNameAuthorToNormal, FBCommandSequenceAuthorToNormal},
        {BBSBrowseBoard, @"[您有信件]", 10, WLButtonNameJumpToMailList, FBCommandSequenceJumpToMailList},
        {BBSBrowseBoard, @"阅读[→,r]", 10, WLButtonNameEnterExcerption, FBCommandSequenceEnterExcerption},
        /* BBSBoardList */
        {BBSBoardList, @"列出[y]", 7, WLButtonNameSwitchDisplayAllBoards, fbSwitchDisplayAllBoards},
        {BBSBoardList, @"排序[S]", 7, WLButtonNameSwitchSortBoards, fbSwitchSortBoards},
        {BBSBoardList, @"搜寻[/]", 7, WLButtonNameSearchBoards, FBCommandSequenceSearchBoards},
        {BBSBoardList, @"切换[c]", 7, WLButtonNameSwitchBoardsNumber, fbSwitchBoardsNumber},
        {BBSBoardList, @"添加[a", 6, WLButtonNameAddBoard, FBCommandSequenceAddBoard},
        {BBSBoardList, @",A]", 3, WLButtonNameAddDirectory, FBCommandSequenceAddDirectory},
        {BBSBoardList, @"移动[m]", 7, WLButtonNameMoveBoard, FBCommandSequenceMoveBoard},
        {BBSBoardList, @"删除[d]", 7, WLButtonNameDeleteBoard, fbDeletePost},
        {BBSBoardList, @"求助[h]", 7, WLButtonNameShowHelp, fbShowHelp},
        {BBSBoardList, @"[您有信件]", 10, WLButtonNameJumpToMailList, FBCommandSequenceJumpToMailList},
        /* BBSFriendList */
        {BBSFriendList, @"聊天[t]", 7, WLButtonNameChatWithUser, FBCommandSequenceChatWithUser},
        {BBSFriendList, @"寄信[m]", 7, WLButtonNameMailToUser, FBCommandSequenceMailToUser},
        {BBSFriendList, @"送讯息[s]", 9, WLButtonNameSendMessageToUser, FBCommandSequenceSendMessageToUser},
        {BBSFriendList, @"加,减朋友[a", 11, WLButtonNameAddUserToFriendList, FBCommandSequenceAddUserToFriendListA},
        {BBSFriendList, @"加,减朋友[o", 11, WLButtonNameAddUserToFriendList, FBCommandSequenceAddUserToFriendListO},
        {BBSFriendList, @",d]", 3, WLButtonNameRemoveUserFromFriendList, FBCommandSequenceRemoveUserFromFriendList},
        {BBSFriendList, @"切换模式 [c]", 12, WLButtonNameSwitchUserListMode, FBCommandSequenceSwitchUserListModeC},
        {BBSFriendList, @"切换模式 [f]", 12, WLButtonNameSwitchUserListMode, FBCommandSequenceSwitchUserListModeF},
        {BBSFriendList, @"求救[h]", 7, WLButtonNameShowHelp, fbShowHelp},
        /* BBSUserInfo */
        {BBSUserInfo, @"信息[i]", 7, WLButtonNameShowUserInfo, FBCommandSequenceShowUserInfo},
        {BBSUserInfo, @"寄信[m]", 7, WLButtonNameMailToUser, FBCommandSequenceMailToUser},
        {BBSUserInfo, @"聊天[t]", 7, WLButtonNameChatWithUser, FBCommandSequenceChatWithUser},
        {BBSUserInfo, @"送讯息[s]", 9, WLButtonNameSendMessageToUser, FBCommandSequenceSendMessageToUser},
        {BBSUserInfo, @"加,减朋友[a", 11, WLButtonNameAddUserToFriendList, FBCommandSequenceAddUserToFriendListA},
        {BBSUserInfo, @"加,减朋友[o", 11, WLButtonNameAddUserToFriendList, FBCommandSequenceAddUserToFriendListO},
        {BBSUserInfo, @",d]", 3, WLButtonNameRemoveUserFromFriendList, FBCommandSequenceRemoveUserFromFriendList},
        {BBSUserInfo, @"切换模式 [f]", 12, WLButtonNameSwitchUserListMode, FBCommandSequenceSwitchUserListModeF},
        {BBSUserInfo, @"求救[h]", 7, WLButtonNameShowHelp, fbShowHelp},
        {BBSUserInfo, @"说明档[l]", 9, WLButtonNameShowUserDescription, FBCommandSequenceShowUserDescriptionL},
        {BBSUserInfo, @"说明档[v]", 9, WLButtonNameShowUserDescription, FBCommandSequenceShowUserDescriptionV},
        {BBSUserInfo, @"选择使用", 8, WLButtonNamePreviousUser, FBCommandSequencePreviousUser},
        {BBSUserInfo, @"者[↑,↓]", 9, WLButtonNameNextUser, FBCommandSequenceNextUser},
        {BBSUserInfo, @"驻版[k]", 7, WLButtonNameShowUserBoards, FBCommandSequenceShowUserBoards},
        {BBSUserInfo, @"短信[w]", 7, WLButtonNameSendSMSToUser, FBCommandSequenceSendSMSToUser},
        /* BBSMessageList */
        {BBSMessageList, @"保留<r>", 7, WLButtonNameRetainMessages, FBCommandSequenceRetainMessages},
        {BBSMessageList, @"清除<c>", 7, WLButtonNameClearMessages, FBCommandSequenceClearMessages},
        {BBSMessageList, @"寄回信箱<m>", 11, WLButtonNameMailMessages, FBCommandSequenceMailMessages},
        {BBSMessageList, @"发讯人<i>", 9, WLButtonNameSearchID, FBCommandSequenceSearchID},
        {BBSMessageList, @"讯息内容<s>", 11, WLButtonNameSearchMessages, FBCommandSequenceSearchMessages},
        {BBSMessageList, @"全部<a>", 7, WLButtonNameShowAllMessages, FBCommandSequenceShowAllMessages},
    };
    
    if (r > 3 && r < _maxRow-1)
        return;
    
    WLTerminal *ds = _view.frontMostTerminal;
    BBSState bbsState = ds.bbsState;
    
    for (int x = 0; x < _maxColumn; ++x) {
        for (int i = 0; i < sizeof(buttonsDefinition) / sizeof(WLButtonDescription); ++i) {
            WLButtonDescription buttonDescription  = buttonsDefinition[i];
            if (bbsState.state != buttonDescription.state)
                continue;
            int length = buttonDescription.signatureLengthOfBytes;
            if (x < _maxColumn - length) {
                if ([[ds stringAtIndex:(x + r * _maxColumn) length:length] isEqualToString:buttonDescription.signature]) {
                    [self addButtonArea:buttonDescription.buttonName
                        commandSequence:buttonDescription.commandSequence
                                  atRow:r
                                 column:x
                                 length:length];
                    x += length - 1;
                    break;
                }
            }
        }
    }
}

- (BOOL)shouldUpdate {
    if (!_view.shouldEnableMouse || !_view.connected) {
        return YES;
    }
    
    // Only update when BBS state has been changed
    BBSState bbsState = _view.frontMostTerminal.bbsState;
    BBSState lastBbsState = _manager.lastBBSState;
    if (bbsState.state == lastBbsState.state &&
        bbsState.subState == lastBbsState.subState)
        return NO;
    
    return YES;
}

- (void)update {
    // Clear & Update
    [self clear];
    if (!_view.shouldEnableMouse || !_view.connected) {
        return;
    }
    for (int r = 0; r < _maxRow; ++r) {
        [self updateButtonAreaForRow:r];
    }
}
@end
