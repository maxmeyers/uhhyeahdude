//
//  MMEpisodeCollectionViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 6/17/13.
//
//

#import "MMEpisodeCollectionViewController.h"
#import "MMEpisodeCollectionViewCell.h"
#import "Media.h"

@interface MMEpisodeCollectionViewController ()

@end

@implementation MMEpisodeCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [EPISODES count];
}

- (UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMEpisodeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EpisodeCell" forIndexPath:indexPath];
    cell.media = [EPISODES objectAtIndex:indexPath.row];
    cell.titleLabel.text = cell.media.title;
    [cell setImage];
    return cell;
}

@end
