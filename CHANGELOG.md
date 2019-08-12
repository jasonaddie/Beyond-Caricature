This page lists additions, changes, and bug fixes that have been applied to the application code.
The numbers in brackets (i.e., [0.1]), indicate the version number of the app.

## [0.53] - 2019-08-12
### Fixed
- Removed old code and libraries that were no longer needed

## [0.52] - 2019-08-12
### Added
- Rotate log files on server so they do not take up disk space

## [0.51] - 2019-08-09
### Added
- Library to view PDF files in the browser (some browsers were just downloading the file)
- Applied some styling to the date filters
- Hover style for the Source, News, and Research cards that appear on list pages

### Fixed
- Date filter down arrow now rotates when the date filter is open (just like the other drop down filters)

## [0.50] - 2019-08-04
### Fixed
- Title on homepage was wrapping at certain screen sizes

## [0.49] - 2019-07-31
### Added
- Upload user cannot view record histories
- Refactored code that tests if nested objects in a form should be saved (i.e., slideshow in the News form)

### Fixed
- Language switcher properly sets URL on issue page
- Editing News and Research records was ignoring new captions in the slideshow

## [0.48] - 2019-07-18
### Added
- Restart the app server on a periodic basis to keep memory usage to a minimum

### Fixed
- Formatting for text entered into rich-textboxes (i.e., lists are displayed as lists)
- Added a retry call when generating image thumbnails in case an error is thrown

## [0.47] - 2019-07-11
### Fixed
- Site Admin email was mis-spelled

## [0.46] - 2019-07-11
### Added
- Google analytics code
- Contact names and emails
- Logo changes color on hover

## [0.45] - 2019-07-08
### Added
- Changed Images to be able to have more than one person assigned to it

## [0.44] - 2019-06-19
### Added
- Contact email on About page
- Link to Facebook group page in footer

## [0.43] - 2019-06-19
### Added
- National Archives of Georgia on About page

## [0.42] - 2019-06-04
### Added
- Last Update column as been added to all admin list pages

### Fixed
- Defined admin search for each data model (i.e., Image, Source, etc)
- If pass in bad filter value (i.e, user changes url and provides bad data), return no matches
- Format Date Made Public in admin pages so it does not include seconds and timezone

## [0.41] - 2019-06-03
### Added
- Ability to export/inport site translations to spreadsheet

### Fixed
- Test if a list filter has content to filter by before showing on page

## [0.40] - 2019-06-03
### Added
- Slug to Role and Publication Language data model
- Source and Image page now show all filters that are available

### Fixed
- Updated code to have better consisten naming patterns
- Person page was not showing journals records where person was assigned through Journal Editors section
- Source and Issue page now show all of images

## [0.39] - 2019-06-01
### Added
- New deafult image for people
- New issue number format with year at the end
- Hide language switcher
- Made email in footer a link
- New Contributors section on About page
- NCEEER logo to About page
- Links in textbox now defualt to open in a new tab

### Fixed
- View all images link from Source page now works
- Tag link on Image page now works
- Changed 'Donor' to 'Funding' on About page
- Removed twitter icon from footer
- Updated stat categories on homepage
- Converted publish date to publish datetime so image records can be sorted by date and time
- Whene delete an image annotation, markers are updated
- Test if date filter exists before trying to work with it
- Image search now working

## [0.38] - 2019-05-27
### Fixed
- Set PDF max file size to 30MB

## [0.37] - 2019-05-26
### Fixed
- Date range calculations had a bug that did not test if data was present before trying to use it

## [0.36] - 2019-05-25
### Fixed
- Emails sent using oskar email address

## [0.35] - 2019-05-25
### Added
- Now have staging and production environements and deployments

## [0.34] - 2019-05-24
### Added
- Image count to meta data in listing pages
- Issue count to meta data for Journals on the Source listnig page
- Source count to meta data in Person listing page
- Date filter ranges are now based on data in the system; if there is no date data, date filter is hidden
- Screen size responsiveness to filters
- x button to remove text in search filter
- x button to remove value for date filter
- In date filter, show the dates that are selected next to the 'Start Date' and 'End Date' labels above the calendar

### Fixed
- Background image of lines now go all the way down
- Source page people roles are now better grouped together
- Calculation of count of illustrations for a person
- View all image links on Source and Issue page now working
- Logic for Person data filter
- Reduced partner/donor logo size
- Default calendar view for date filter will either be the first date (for Source, Image, Person) or most recent date (for News and Resaerch)
- Overrode the datepicker library script so that it works when no dates are selected (can have end date with no start date)
- Removed old code

## [0.33] - 2019-05-20
### Added
- Partner and Donor logos
- Site share image
- Use cover image on detail pages for the share image (i.e., Source, Image, Person, News Item, Research Item)

### Fixed
- Homepage adjustments
    - Reduced content width
    - Shrunk the background illustrations a bit
    - Fixed slideshow height calculation

## [0.32] - 2019-05-16
### Added
- Loading image when using search or filter
- Shadow to highlight images
- Small animation when hover over menu item or language switcher
- Fonts to use for Georgian language

### Fixed
- Language switch styling
- Make logo in navbar bigger
- Width of menu items for mobile
- Make menu font bolder
- Remove shadow for around the listing blocks
- Increase space for text on listing blocks that show text on top of image when hover over block (i.e., Image and Person pages)
- Increase about page text width
- All page headers are now bold
- On News and Research listing pages, decrease space between image and title
- Change background color in the view more popups
- View all links on person page now work
- Updated date filter queries
- Decrease summary character length for List View on listing pages so text does not go past image
- Not show grid / list view buttons on News and Research pages
- Make left side of menu and page content line up
- Related Items on the News and Research page now appears as a sidebar on widescreen monitors
- Change date filter 'close' button to 'confirm'
- Update all font sizes to use REM units instead of PX


## [0.31] - 2019-05-14
### Added
- Crop alignment field to data models with images that appear in lists (i.e., Source, Issue, Image, Person, News, Research)
    - This field allows admins to indicate what part of the image to use when creating the thumbnail for list pages

### Fixed
- Language switcher loads entire page so language attributes are properly loaded
- Consolidated all image size references into one method

## [0.30] - 2019-05-14
### Fixed
- Search/filter was not properly updating the url

## [0.29] - 2019-05-14
### Added
- Add search and filters to Sources, People, Images, News and Research pages

## [0.28] - 2019-05-12
### Fixed
- Sort records on public Peoples page by last name, first name

## [0.27] - 2019-05-12
### Fixed
- Split Person name field into first and last name field
- Sort records on public Sources page by source title ascending
- Label for related items header in News/Research public pages
- Increased title size and decreased size of meta text for the cards on the listing pages (i.e., Home, Sources, Images, People, News, Research)
- Changed Illustrations to Images (i.e., URL, text labels, etc)
- Changed public Person page so that any role can show the card for an illustration or a source
- Highlights text is no longer centered

### Added
- Format for Issue number: № 4

## [0.26] - 2019-05-02
### Added
- Pagination to the list pages: Sources, Issues, Illustrations, People, News and Research
- Grid and list view to list pages: Sources, Illustrations and People

### Fixed
- Images in slideshow are now centered
- Better responsiveness for grid displays on Sources, Illustrations and People

## [0.25] - 2019-05-01
### Added
- Mouse scroll icon to homepage
- Share links to the right side of the window

### Fixed
- Font sizes in the list cards where text appears below the image
- Homepage illustration background positioning
- Homepage slideshow title positioning

## [0.24] - 2019-04-29
### Fixed
- Updated language to Latin conversion for record URLs
- Update slideshows:
    - in form, slideshow entries are properly sorted when editing an existing record
    - in form, update sort values when add new slideshow item
    - in News and Research pages, updated slideshow height so it adjusts based on image height

## [0.23] - 2019-04-27
### Added
- Combined listing of illustrations and sources for illustrator role on person page
- Logic to determine if allow or block search engine scraping (not want on test site)

### Fixed
- Bug on Research data model due to mis-spelling

## [0.22] - 2019-04-26
### Fixed
- The drop down to add related people to a record was not opening
- Updated Russian to Latin conversion for record URLs

## [0.21] - 2019-04-25
### Fixed
- Reset size of background illustrations on homepage to original size
- View PDF links fixed
- Generating Issue slugs
- Gave admin's access to new Page Text section
- Turn off home link in navbar

## [0.20] - 2019-04-24
### Fixed
- Fonts were not properlly being loaded
- Reduced size of background illustrations on homepage

## [0.19] - 2019-04-22
### Added
- Total illustrations into the view all button in the Source, Issue, and Person detail pages
- Image size into the help text that appears for image fields in the forms
- Page Text data model to allow admin to manage the content on the homepage and about page
- Missing Aremenian date and time format setting

### Fixed
- Email notification settings
- All URL slugs (i.e., the url of the record like /person/oskar-schmerling) are unique and get updated when the data is updated

## [0.18] - 2019-04-17
### Added
- Style to the Issue detail page
- Style to the Source detail page

## [0.17] - 2019-04-17
### Added
- Style to the Illustration detail page and annotations

### Fixed
- Updated layout of pages to use columns

## [0.16] - 2019-04-13
### Added
- Flag to Person Role data model to know if person is an illustrator

## [0.15] - 2019-04-13
### Added
- Popup to view full image on Person detail page
- Person Role data model with admin form to manage the records

## [0.14] - 2019-04-11
### Added
- Style to the Person detail page

## [0.13] - 2019-04-11
### Fixed
- Update role permissions for admin navigation menu
- Update public menu so current page is properly highlighted

## [0.12] - 2019-04-09
### Added
- Style ro the News and Research detail pages
- Slideshow to News and Research detail pages
- Highlight slideshow to home page

## [0.11] - 2019-03-27
### Added
- Default image to be used when a record does not have an image (i.e., cover image)
- Implmeneted a max-width for the content (1364px)
- Favicons (i.e., the icon that appears in the browser tab)
- Basic styling for the Source, People, and Illustration listing pages
- Style to the News and Research listing pages
- New generic Person data model that replaces the Illustrator data model
    - Updated Source form so admin can select an existing person and assign a role to them (i.e., illustrator, publisher, editor, etc)
    - Change name of public pages from Illustrators to People
    - Public page now shows all people (not just illustrators) and indicates what roles they have

### Fixed
- On mobile, popup menu does not open after going to a new page
- Image size in cards (i.e., images in listings)
- Navbar is no longer fixed to the top of the window

## [0.10] - 2019-03-12
### Added
- Public pages navbar and footer
- Public pages basic styling
- Homepage and about page have been styled
- Added meta tag management for public pages (seo, sharing, etc.)

### Fixed
- All users can now access the change log page

## [0.9] - 2019-03-04
### Added
- Tags to public Illustration page
- Caption to News/Research slideshow images
- In News/Research slideshows and Illustration annotation, added a new 'add' button to the bottom of the section so user does not have to scroll up to click on add button at the top of the section
- Logo to admin header

### Fixed
- Updated text label from Publication to Source
- Updated public url for /publications to /sources
- Slug generation (unique URL name) is only created if the title is entered for the slug
- Language switcher now uses the correct locale slug
- New form with language tabs - changing tabs properly changes the associated language form fields
- Delete button now works for News/Research slideshows and Illustration annotation

## [0.8] - 2019-02-22
### Added
- Help text for image and file form fields to indicate what file types are allowed and any file size limits
- Link to view PDFs now include file size
- Error notification service

### Fixed
- In Publication Editor form fields and Illustration Annotation form fields, switching language tabs properly works now
- If pre-defined lists (i.e., publication types) are translated in the forms, on edit, an existing value is not properly selected. As temporary fix, turned off translating pre-defined lists
- Illustration annotation marker numbers are properly updated after sorting
- News/Research Slideshow and Illustration Annotation sections are visible by default if items exist in the section
- Illustration Annotation markers are loaded by default when an existing record is opened

## [0.7] - 2019-01-30
### Fixed
- Issue form now opens without throwing an error

## [0.6] - 2019-01-30
### Changed
- Updated the changelog content

## [0.5] - 2019-01-30
### Added
- Ability to control sort order by dragging/dropping items in News/Research Slideshows and Illustration Annotations
- Ability to place illustration annotation markers on image
- Change Log page to admin section so admins can see what is happening with the app

### Fixed
- In popup forms that have rich-text editors, the text entered into the rich-text editor field is now saved

## [0.4] - 2019-01-21
### Added
- Theme colors that match publc page design colors
- Ability to translate enumeration values that are used in Publication > Publication Type and Related Item > Related Item Type
- Basic Illustration Annotation process - can enter text but cannot yet indicate where on image text is located

### Changed
- Updated application README with details about system requirements and how to use Docker
- Turned off ability to create Publication records from the Issue form
- Is Public? colors for list pages to better match theme colors

### Fixed
- Checking all translation fields in Journal Editor records to determine if any content was added

## [0.3] - 2019-01-18
### Fixed
- Turn off ability for anyone to create accounts

## [0.2] - 2019-01-17
### Fixed
- Only use .env files during development, not in production

## [0.1] - 2019-01-17
### Added
- Docker containers with ability to deploy to server

### Note
- This was the first created version but the app was already well build by then with a mostly working admin section and basic public pages
