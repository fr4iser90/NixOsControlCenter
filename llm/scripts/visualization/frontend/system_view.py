"""Frontend view for system monitoring."""
import streamlit as st
import plotly.express as px
import pandas as pd
from typing import Dict
from ..backend.system_monitor import SystemMonitor

class SystemView:
    """View for system monitoring visualization."""
    
    def __init__(self, system_monitor: SystemMonitor):
        """Initialize system view.
        
        Args:
            system_monitor: System monitor instance
        """
        self.system_monitor = system_monitor
        
    def render(self):
        """Render the system monitoring view."""
        st.header("System Monitor")
        
        # Get system metrics
        metrics = self.system_monitor.get_system_metrics()
        
        # Display alerts if any
        if metrics['alerts']:
            for alert in metrics['alerts']:
                st.warning(alert)
                
        # Resource Usage Overview
        st.subheader("Resource Usage Overview")
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("CPU Usage", f"{metrics['cpu_percent']}%")
            
        with col2:
            st.metric(
                "Memory Usage",
                f"{metrics['memory_percent']}%",
                f"{metrics['memory_used']:.1f}/{metrics['memory_total']:.1f} GB"
            )
            
        with col3:
            st.metric(
                "Disk Usage",
                f"{metrics['disk_percent']}%",
                f"{metrics['disk_used']:.1f}/{metrics['disk_total']:.1f} GB"
            )
            
        with col4:
            if metrics['gpu_available']:
                st.metric(
                    "GPU Usage",
                    f"{metrics['gpu_utilization']}%",
                    f"{metrics['gpu_memory_used']:.1f}/{metrics['gpu_memory_total']:.1f} GB"
                )
            else:
                st.metric("GPU", "Not Available")
                
        # Resource History Plots
        st.subheader("Resource History")
        fig = self.system_monitor.plot_resource_history()
        if fig:
            st.plotly_chart(fig, use_container_width=True)
            
        # Process Information
        st.subheader("Training Processes")
        processes = self.system_monitor.get_training_processes()
        if processes:
            # Convert process info to DataFrame for better display
            df = pd.DataFrame(processes)
            df['create_time'] = pd.to_datetime(df['create_time'], unit='s')
            df['runtime'] = (pd.Timestamp.now() - df['create_time']).dt.total_seconds() / 60
            
            # Format columns for display
            display_df = df[[
                'pid', 'name', 'cpu', 'memory', 'status',
                'threads', 'open_files', 'connections', 'runtime'
            ]].copy()
            
            display_df['cpu'] = display_df['cpu'].map('{:.1f}%'.format)
            display_df['memory'] = display_df['memory'].map('{:.1f}%'.format)
            display_df['runtime'] = display_df['runtime'].map('{:.1f} min'.format)
            
            # Rename columns for better readability
            display_df.columns = [
                'PID', 'Name', 'CPU Usage', 'Memory Usage', 'Status',
                'Threads', 'Open Files', 'Connections', 'Runtime'
            ]
            
            st.dataframe(
                display_df,
                use_container_width=True,
                hide_index=True
            )
        else:
            st.info("No active training processes found")
