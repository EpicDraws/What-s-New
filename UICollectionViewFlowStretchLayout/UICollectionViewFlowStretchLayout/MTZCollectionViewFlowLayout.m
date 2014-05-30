//
//  MTZCollectionViewFlowLayout.m
//  MTZCollectionViewFlowLayout
//
//  Created by Matt Zanchelli on 5/29/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZCollectionViewFlowLayout.h"

@implementation MTZCollectionViewFlowLayout

- (id)init
{
	self = [super init];
	if (self) {
		self.treatSizeAsMinimumSize = YES;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.treatSizeAsMinimumSize = YES;
	}
	return self;
}


#pragma mark - Properties

- (void)setTreatSizeAsMinimumSize:(BOOL)treatSizeAsMinimumSize
{
	_treatSizeAsMinimumSize = treatSizeAsMinimumSize;
	
	UICollectionViewFlowLayoutInvalidationContext *ctx = [[UICollectionViewFlowLayoutInvalidationContext alloc] init];
	ctx.invalidateFlowLayoutDelegateMetrics = YES;
	[self invalidateLayoutWithContext:ctx];
}


#pragma mark - Providing Layout Attributes

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSArray *allAttributes = [super layoutAttributesForElementsInRect:rect];
    for ( UICollectionViewLayoutAttributes *attributes in allAttributes ) {
        if ( !attributes.representedElementKind ) {
            NSIndexPath *indexPath = attributes.indexPath;
            attributes.frame = [self layoutAttributesForItemAtIndexPath:indexPath].frame;
        }
    }
    return allAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
	
	if ( self.treatsSizeAsMinimumSize ) {
		// Get some basic measurements.
		UIEdgeInsets sectionInset;
		if ( [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)] ) {
			[((id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self insetForSectionAtIndex:indexPath.section];
		} else {
			sectionInset = self.sectionInset;
		}
		
		CGFloat interItemSpacing;
		if ( [self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)] ) {
			interItemSpacing = [((id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate) collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:indexPath.section];
		} else {
			interItemSpacing = self.minimumInteritemSpacing;
		}
		
		// Measurements dependent on scroll direction.
		CGFloat totalDimension, totalSectionInset, minimumItemDimension;
		
		switch (self.scrollDirection) {
			case UICollectionViewScrollDirectionVertical:
				totalDimension = self.collectionView.bounds.size.width;
				totalSectionInset = sectionInset.left + sectionInset.right;
				minimumItemDimension = self.itemSize.width;
				break;
			case UICollectionViewScrollDirectionHorizontal:
				totalDimension = self.collectionView.bounds.size.height;
				totalSectionInset = sectionInset.top + sectionInset.bottom;
				minimumItemDimension = self.itemSize.height;
				break;
		}
		
		// Calculate the new dimension based on working dimension and number of items in a line.
		CGFloat workingDimension = totalDimension - totalSectionInset;
		CGFloat numberOfItemsInLine = floor((workingDimension - interItemSpacing) / (minimumItemDimension + interItemSpacing));
		CGFloat newDimension = MAX(minimumItemDimension, workingDimension / numberOfItemsInLine);
		
		// Set the new size and set back the center.
		CGPoint originalCenter = attributes.center;
		switch (self.scrollDirection) {
			case UICollectionViewScrollDirectionVertical:
				attributes.size = CGSizeMake(newDimension, attributes.size.height);
				break;
			case UICollectionViewScrollDirectionHorizontal:
				attributes.size = CGSizeMake(attributes.size.width, newDimension);
				break;
		}
		attributes.center = originalCenter;
	}
	
	return attributes;
}


#pragma mark - Invalidating the Layout

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
	// This cast should hopefully never cause issues. `super` should always return `UICollectionViewFlowLayoutInvalidationContext`.
	UICollectionViewFlowLayoutInvalidationContext *ctx = (UICollectionViewFlowLayoutInvalidationContext *) [super invalidationContextForBoundsChange:newBounds];
	ctx.invalidateFlowLayoutDelegateMetrics = YES;
	return ctx;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
	/*
	// Only bother if this option is set.
	if ( self.treatSizeAsMinimumSize ) {
		// The new and old dimension (that we care about)
		CGFloat newDimension, oldDimension;
		// Set the new/old dimension according to scroll direction.
		switch (self.scrollDirection) {
			case UICollectionViewScrollDirectionVertical:
				newDimension = newBounds.size.width;
				oldDimension = self.collectionView.bounds.size.width;
				break;
			case UICollectionViewScrollDirectionHorizontal:
				newDimension = newBounds.size.height;
				oldDimension = self.collectionView.bounds.size.height;
				break;
		}
		
		// If the dimension we care about changed, invalidate.
		if ( newDimension != oldDimension ) {
			return YES;
		}
	}
	 */
	
	return [super shouldInvalidateLayoutForBoundsChange:newBounds];
}

@end