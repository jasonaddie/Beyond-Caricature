This page lists additions, changes, and bug fixes that have been applied to the application code.
The numbers in brackets (i.e., [0.1]), indicate the version number of the app.

## [Unreleased]
These are items that are have been finished, but not released yet.

None at this time.

## [0.27] - 2019-05-12
### Fixed
- Split Person name field into first and last name field
- Sort records on public Peoples page by last name, first name
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
