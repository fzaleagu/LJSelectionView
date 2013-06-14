//
//  LJSelectionViewController.m
//  LJSelectionViewDemo
//
//  Created by Matthew Smith on 6/11/13.
//  Copyright (c) 2013 lattejed.com. All rights reserved.
//

#import "LJSelectionViewController.h"

@interface LJSelectionViewController ()

- (NSView *)viewForPoint:(NSPoint)point;
- (NSSet *)viewsInRect:(NSRect)rect;

@end

@implementation LJSelectionViewController

- (id)init;
{
    self = [super init];
    if (self) {
        _selectionBehavior = kSelectionBehaviorPartial;
        _dragType = kDragTypeNone;
        _selectionRect = NSZeroRect;
    }
    return self;
}

#pragma mark - Selection management

- (void)addViewsToSelection:(NSSet *)views append:(BOOL)append;
{
    [[_undoManager prepareWithInvocationTarget:self] setSelectedSubviews:_selectedSubviews];
    if (append) {
        if (!_selectedSubviews) {
            self.selectedSubviews = [NSSet set];
        }
        [_undoManager setActionName:NSLocalizedString(@"Add To Selection", @"")];
        self.selectedSubviews = [_selectedSubviews setByAddingObjectsFromSet:views];
    }
    else {
        [_undoManager setActionName:NSLocalizedString(@"Select", @"")];
        self.selectedSubviews = [views copy];
    }
}

- (void)clearSelection;
{
    [[_undoManager prepareWithInvocationTarget:self] setSelectedSubviews:_selectedSubviews];
    [_undoManager setActionName:NSLocalizedString(@"Clear Selection", @"")];
    self.selectedSubviews = nil;
}

#pragma mark - LJSelectionViewDelegate

- (void)selectionView:(LJSelectionView *)aSelectionView didSingleClickAtPoint:(NSPoint)point flags:(NSUInteger)flags;
{
    NSView* view = [self viewForPoint:point];
    if (view) {
        if (flags & NSShiftKeyMask) {
            [self addViewsToSelection:[NSSet setWithObject:view] append:YES];
        }
        else {
            [self addViewsToSelection:[NSSet setWithObject:view] append:NO];
        }
    }
}

- (void)selectionView:(LJSelectionView *)aSelectionView didDoubleClickatPoint:(NSPoint)point flags:(NSUInteger)flags;
{
    // Optional protocol method to handle single click in the view
}

- (BOOL)selectionView:(LJSelectionView *)aSelectionView shouldDragFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 delta:(NSPoint)delta flags:(NSUInteger)flags;
{
    if (_dragType == kDragTypeNone) {
        
        // If you want other drag options besides selection in your view, you can select drag types here.
        _dragType = kDragTypeSelect;
    }
    
    switch (_dragType) {
        case kDragTypeSelect:
            _selectionRect = NSMakeRect(p1.x, p1.y, p2.x+p1.x, p2.y+p1.y);
            break;
        default:
            break;
    }
    
    // Returning NO in this method prevents the drag from continuting.
    return YES;
}

- (void)selectionView:(LJSelectionView *)aSelectionView didFinishDragFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 delta:(NSPoint)delta flags:(NSUInteger)flags;
{
    if (_dragType == kDragTypeSelect) {
        NSSet* views = [self viewsInRect:NSMakeRect(p1.x, p1.y, p2.x+p1.x, p2.y+p1.y)];
        if ([views count]) {
            if (flags & NSShiftKeyMask) {
                [self addViewsToSelection:views append:YES];
            }
            else {
                [self addViewsToSelection:views append:NO];
            }
        }
        _selectionRect = NSZeroRect;
    }
    _dragType = kDragTypeNone;
}

- (NSRect)selectionViewRectForSelection;
{
    return _selectionRect;
}

#pragma mark - Private methods

- (NSView *)viewForPoint:(NSPoint)point;
{
    for (NSView* view in [_selectionView subviews]) {
        if (NSPointInRect(point, [view frame])) {
            return view;
        }
    }
    return nil;
}

- (NSSet *)viewsInRect:(NSRect)rect;
{
    NSSet* views = [NSSet set];
    for (NSView* view in [_selectionView subviews]) {
        if ( (_selectionBehavior == kSelectionBehaviorPartial   && NSIntersectsRect(view.frame, rect)) ||
             (_selectionBehavior == kSelectionBehaviorFull      && NSContainsRect(view.frame, rect))) {
            views = [views setByAddingObject:view];
        }
    }
    return views;
}

@end
