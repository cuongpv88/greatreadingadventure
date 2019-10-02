﻿using System;
using System.Collections.Generic;
using GRA.Domain.Model;

namespace GRA.Controllers.ViewModel.MissionControl.PerformerScheduling
{
    public class PerformerViewModel
    {
        public PsPerformer Performer { get; set; }
        public PsSettings Settings { get; set; }
        public GRA.Domain.Model.System System { get; set; }
        public string ImagePath { get; set; }
        public Uri Uri { get; set; }
        public ICollection<PsAgeGroup> AgeGroups { get; set; }

        public int? NextPerformer { get; set; }
        public int? PrevPerformer { get; set; }
        public int ReturnPage { get; set; }
        public string ReferencesPath { get; set; }

        public ICollection<int> BranchAvailability { get; set; }
        public ICollection<PsBlackoutDate> BlackoutDates { get; set; }
    }
}
