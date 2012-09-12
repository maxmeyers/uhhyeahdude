//
//  MMFilesViewController.m
//  UhhYeahDude
//
//  Created by Max Meyers on 9/11/12.
//
//

#import "MMFilesViewController.h"
#import "MMAppDelegate.h"
#import "MMMedia.h"
#import "MMEpisodeDataSource.h"
#import "MMVideoDataSource.h"
#import "MMVideoSection.h"

@implementation MMFilesViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.recentlyEmptied = [NSMutableArray array];
    
    dispatch_async(dispatch_queue_create("file_lister", NULL), ^{
        NSMutableArray *tempEpisodes = [NSMutableArray array];
        NSMutableArray *tempVideos = [NSMutableArray array];
        NSMutableDictionary *tempFileSizes = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *episodesByFileName = [NSMutableDictionary dictionary];
        for (MMMedia *media in [[MMEpisodeDataSource sharedDataSource] episodes]) {
            [episodesByFileName setObject:media forKey:media.fileName];
        }
        
        NSMutableDictionary *videosByFileName = [NSMutableDictionary dictionary];
        for (MMVideoSection *section in [[MMVideoDataSource sharedDataSource] sections]) {
            for (MMMedia *media in [section items]) {
                [videosByFileName setObject:media forKey:media.fileName];                
            }
        }

        for (NSString *fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:MEDIA_DIRECTORY error:nil]) {
            MMMedia *media = [episodesByFileName objectForKey:fileName];
            if (media) {
                [tempEpisodes addObject:media];
            } else {
                media = [videosByFileName objectForKey:fileName];
                if (media) {
                    [tempVideos addObject:media];
                }
            }
            
            if (media) {
                NSNumber *fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", MEDIA_DIRECTORY, fileName] error:nil] objectForKey:NSFileSize];
                float fileSizeInMB = [fileSize intValue] / 1048576;
                [tempFileSizes setObject:[NSNumber numberWithFloat:fileSizeInMB] forKey:media.fileName];
            }

        }
        [self setEpisodes:[NSArray arrayWithArray:tempEpisodes]];
        [self setVideos:[NSArray arrayWithArray:tempVideos]];
        [self setFileSizes:[NSDictionary dictionaryWithDictionary:tempFileSizes]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self tableView] reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Episodes";
            break;
        case 1:
            return @"Videos";
            break;
            
        default:
            return @"";
            break;
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSArray *container = [self containerForSection:section];
    if (container) {
        int sum = 0;
        for (MMMedia *media in container) {
            NSNumber *size = [[self fileSizes] objectForKey:media.fileName];
            sum += [size longLongValue];
        }
        return [NSString stringWithFormat:@"Total: %d MB", sum];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSArray *)containerForSection:(NSInteger)section
{
    if (section == 0) {
        return self.episodes;
    } else if (section == 1) {
        return self.videos;
    }
    return nil;
}

- (void)setContainer:(NSArray *)container forSection:(NSInteger)section
{
    if (section == 0) {
        self.episodes = container;
    } else if (section == 1) {
        self.videos = container;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.recentlyEmptied indexOfObject:[NSNumber numberWithInt:section]] != NSNotFound) {
        [self.recentlyEmptied removeObject:[NSNumber numberWithInt:section]];
         
        int64_t delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.tableView reloadData];
        });
        return 0;
    }
    
    NSArray *container = [self containerForSection:section];
    if (container) {
        return container.count > 0 ? container.count : 1;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *container = [self containerForSection:indexPath.section];
    if (!container) {
        return [tableView dequeueReusableCellWithIdentifier:@"LoadingFileCell"];
    }

    if (container.count == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"NoFileCell"];
    }
    
    static NSString *CellIdentifier = @"FileCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.row < container.count) {
        MMMedia *media = [container objectAtIndex:indexPath.row];
        cell.textLabel.text = media.shortTitle;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ MB",[self.fileSizes objectForKey:media.fileName]];
    }
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *container = [self containerForSection:indexPath.section];
    if (container && container.count > 0) {
        return YES;
    }
    
    return NO;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *container = [self containerForSection:indexPath.section];
        if (container) {
            NSMutableArray *tempNewContainer = [NSMutableArray arrayWithArray:container];
            MMMedia *deletedMedia = [tempNewContainer objectAtIndex:indexPath.row];
            deletedMedia.fileStatus = NotAvailable;
            [tempNewContainer removeObject:deletedMedia];
            [self setContainer:[NSArray arrayWithArray:tempNewContainer] forSection:indexPath.section];
            
            
            if (tempNewContainer.count == 0) {
                [self.recentlyEmptied addObject:[NSNumber numberWithInt:indexPath.section]];
            }
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", MEDIA_DIRECTORY, deletedMedia.fileName] error:nil];
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
