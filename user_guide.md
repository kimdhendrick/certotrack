# CertoTrack User Guide

## Setup

* Create Locations

## Equipment

* Status
    * Valid - Not yet expired, not expiring soon
    * Warning - Expiring within 2 months
    * Expired - Past the date for inspection
    * N/A - Inspection not required

### Create Equipment

* Name - must be unique within your company
    * Required
    * Autocomplete matches by 'contains' on name [TBD]
* Serial Number
    * Must be unique within customer
    * Required
* Assignee - Unassigned, Employee or Location
* Inspection Interval
    * 1 month - 5 years
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
* Required Units
   * If entered, becomes 'units based' certification type
* Interval
    * 1 month - 5 years
    * Not Required

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
