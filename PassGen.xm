#import <UIKit/UIKit.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

NSInteger passwordLength = 10;

@interface SFEditableTableViewCell : UITableViewCell
- (UITextField *)_editableTextField;
@end

@interface SFAddPasswordViewController : UITableViewController {
	SFEditableTableViewCell *_passwordCell;
}
- (void)characterStepperChanged:(UIStepper *)stepper;
- (void)generatePassword;
@end

%hook SFAddPasswordViewController
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return %orig;
	}
	return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return %orig;
	}
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			UIStepper *characterStepper = [[UIStepper alloc] initWithFrame:CGRectMake(cell.contentView.bounds.size.width - 65, 4, 60, 48)];
			characterStepper.value = 10;
			characterStepper.minimumValue = 8;
			characterStepper.maximumValue = 100;
			characterStepper.tintColor = [UIColor labelColor];
			[characterStepper addTarget:self action:@selector(characterStepperChanged:) forControlEvents:UIControlEventValueChanged];  
		
			cell.accessoryView = characterStepper;

			cell.textLabel.text = [NSString stringWithFormat:@"Length: %ld", (NSInteger)((UIStepper *)cell.accessoryView).value];
		} else if (indexPath.row == 1) {
			UIButton *generateButton = [UIButton buttonWithType:UIButtonTypeCustom];
			generateButton.translatesAutoresizingMaskIntoConstraints = NO;
			[generateButton addTarget:self action:@selector(generatePassword) forControlEvents:UIControlEventTouchUpInside];
			[generateButton setTitle:@"Generate Password" forState:UIControlStateNormal];
			[generateButton setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
			[cell.contentView addSubview:generateButton];

			[NSLayoutConstraint activateConstraints:@[
				[generateButton.centerXAnchor constraintEqualToAnchor:cell.contentView.centerXAnchor],
				[generateButton.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
				[generateButton.widthAnchor constraintEqualToConstant:cell.contentView.bounds.size.width],
				[generateButton.heightAnchor constraintEqualToConstant:cell.contentView.bounds.size.height],
			]];
		}
	}
	return cell;
}
- (BOOL)tableView:(id)arg0 shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL highlight = %orig;
	if (indexPath.section == 1) {
		if (indexPath.row == 1) {
			highlight = YES;
		}
	}
	return highlight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		%orig;
	} else if (indexPath.section == 1) {
		if (indexPath.row == 1) {
			[self generatePassword];
		}
	}
}
%new
- (void)characterStepperChanged:(UIStepper *)stepper {
	passwordLength = stepper.value;
	UITableViewCell *cell = (UITableViewCell *)stepper.superview;
	cell.textLabel.text = [NSString stringWithFormat:@"Length: %ld", passwordLength];
}
%new
- (void)generatePassword {
	int i, r = 0;
	srand((unsigned int)(time(NULL)));
	char numbers[] = "0123456789";
    char letter[] = "abcdefghijklmnoqprstuvwyzx";
    char LETTER[] = "ABCDEFGHIJKLMNOQPRSTUYWVZX";
    char symbols[] = "!@#$^&*?";
	char password[passwordLength];

	for (i = 0; i < passwordLength; i++) {
        if (r == 1) {
            password[i] = numbers[rand() % 10];
            r = rand() % 4;
        } else if (r == 2) {
            password[i] = symbols[rand() % 8];
            r = rand() % 4;
        } else if (r == 3) {
            password[i] = LETTER[rand() % 26];
            r = rand() % 4;
        } else {
            password[i] = letter[rand() % 26];
            r = rand() % 4;
        }
    }

	NSString *generated = [NSString stringWithCString:password encoding:NSUTF8StringEncoding];
	NSLog(@"[+] PASSGEN DEBUG: Generated -> %@", generated);

	[[MSHookIvar<SFEditableTableViewCell *>(self, "_passwordCell") _editableTextField] setText:generated];
}
%end