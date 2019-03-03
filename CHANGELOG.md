This page lists additions, changes, and bug fixes that have been applied to the application code.
The numbers in brackets (i.e., [0.1]), indicate the version number of the app.

## [Unreleased]
These are items that are have been finished, but not released yet.

### Added
- Tags to public Illustration page
- Caption to News/Research slideshow images
- In News/Research slideshows and Illustration annotation, added a new 'add' button to the bottom of the section so user does not have to scroll up to click on add button at the top of the section

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
