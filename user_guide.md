# CertoTrack User Guide

## Setup

* Create Locations

## Employee

### Create Employee

* First Name
    * Required
* Last Name
    * Required
* Employee Number
    * Required
    * Must be unique within customer
* Location

### Show Employee

* Employee information
* Employee's certifications
    * Certification Type link goes to Show Certification page
    * Units shows units achieved/required if units based certification
    * Certification Type and Status columns are sortable
* Edit
* Delete
   * Prevented if any equipment or certifications assigned, can deactivate instead
* New Employee Certification
   * Certification Type
   * Create Certification Type link
   * Trainer
   * Last Certification Date
       * Required
   * Comments

### All Employees Report

* All employees

### Deactivated Employees Report

* Deactivated employees, contact support for more information on deactivated employees

## Equipment

* Status
    * Valid - Not yet expired, not expiring soon
    * Warning - Expiring within 2 months
    * Expired - Past the date for inspection
    * N/A - Inspection not required

### Create Equipment

* Name
    * Required
    * Must be unique within your customer
    * Autocomplete matches by 'contains' on name
* Serial Number
    * Required
    * Must be unique within customer
* Assignee - Unassigned, Employee or Location
* Inspection Interval
    * 1 month - 5 years
    * Quarterly/Annually - calculates the first day of the next quarter of the following year
    * Not Required
* Last Inspection Date (mm/dd/yyyy)
    * Required if inspection interval selected
    * Will get confirmation if future date entered

### Show Equipment

* Expiration Date - automatically calculated

### Update Equipment

### Delete Equipment

### Search Equipment

* Search box from home page searches for equipment with matching name.
* Autocomplete matches by 'contains' on name
* Clicking Search button from home page without entering value shows full search page with all results.
* Search Page uses 'or' for all fields
* Can enter Name, Serial Number, Location, or Employee
* Name and Serial Number match any equipment with a 'contains' search
* Sortable fields

### All Equipment Report

* Sortable columns
    * Assignee sorts by name, locations and employees intermingled.
* Inspection Interval sorts by duration.

### Expired Equipment Report

* Expired only

### Equipment Expiring Soon Report

* Expiring within the next 2 months

### Non-Inspectable Equipment Report

*  Equipment without an inspection interval

## Certification

* Certification Types
    * Date Based
        * Valid - Not yet expired, not expiring soon
        * Warning - Expiring within 2 months
        * Expired - Past the date for inspection
        * N/A - Certification not required
    * Units Based
        * Valid - Achieved at least minimum required units
        * Pending - Have not yet achieved minimum required units, interval not yet expired
        * Recertify - Failed to achieve minimum required units in interval specified

### Create Certification Type

* Name
    * Required
    * Must be unique within customer
* Required Units
   * If entered, becomes 'units based' certification type
* Interval
    * 1 month - 5 years
    * Quarterly/Annually - calculates the first day of the next quarter of the following year
    * Not Required

### Search Certification Type

* Name contains search

## Vehicle

# CertoTrack Administrator Guide

### General
* All equipment, certifications, vehicles, assigned to one customer
* 25 items per page in reports
* Reports sortable, default to ascending, empty values on bottom

### Create Customers

* Grant access
    * Equipment
    * Certification
    * Vehicle

* Create Users
    * Notification

* Create Locations
