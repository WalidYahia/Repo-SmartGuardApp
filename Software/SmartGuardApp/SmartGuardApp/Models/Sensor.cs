using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SmartGuardApp.Models
{
    public class Sensor
    {
        public string SensorId { get; set; }

        public string UnitId { get; set; }

        public int SwitchNo { get; set; }

        public string Name { get; set; }

        public string? Url { get; set; }

        public UnitType Type { get; set; }

        public DateTime CreatedAt { get; set; }

        public DateTime LastSeen { get; set; }

        public bool IsInInchingMode { get; set; }

        public int InchingModeWidthInMs { get; set; }

        public object LatestValue { get; set; }

        public string? FwVersion { get; set; }

        public bool IsOn {
            get
            {
                if (LatestValue == null)
                    return false;

                else
                    return Convert.ToInt32(LatestValue.ToString()) > 0;
            }
        }
    }
}
